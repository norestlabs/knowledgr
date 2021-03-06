#pragma once

#include <cstdint>

#include <fc/saturation.hpp>
#include <fc/uint128.hpp>
#include <fc/time.hpp>
#include <fc/exception/exception.hpp>
#include <fc/reflect/reflect.hpp>

namespace knowledgr { namespace chain { namespace util {

struct manabar_params
{
   int64_t    max_mana         = 0;
   uint32_t   regen_time       = 0;

   manabar_params() {}
   manabar_params( int64_t mm, uint32_t rt )
      : max_mana(mm), regen_time(rt) {}

   void validate()const
   {
      FC_ASSERT( max_mana >= 0 );
   }
};

struct manabar
{
   int64_t    current_mana     = 0;
   uint32_t   last_update_time = 0;

   manabar() {}
   manabar( int64_t m, uint32_t t )
      : current_mana(m), last_update_time(t) {}

   void regenerate(uint32_t now) {
	   int64_t elapsed_seconds = int64_t(now - last_update_time);
	   int64_t regenerated_power = (KNOWLEDGR_100_PERCENT * elapsed_seconds) / KNOWLEDGR_VOTING_MANA_REGENERATION_SECONDS;
	   current_mana = std::min( current_mana + regenerated_power, int64_t(KNOWLEDGR_100_PERCENT) );
	   last_update_time = now;
   }
   static uint128_t calculate_mana_to_be_used(manabar voting_manabar, int64_t percent, int64_t votes_num_per_day) {
	   uint128_t used_mana = ( uint128_t( voting_manabar.current_mana ) * percent * 60 * 60 * 24 ) / KNOWLEDGR_100_PERCENT;
	   int64_t max_vote_denom = votes_num_per_day * KNOWLEDGR_VOTING_MANA_REGENERATION_SECONDS;
	   std::cerr<<"~~~ [manabar::calculate_mana_to_be_used()] - max_vote_denom = "<<max_vote_denom<<"\n";
	   FC_ASSERT( max_vote_denom > 0 );

	   used_mana = ( used_mana + max_vote_denom - 1 ) / max_vote_denom;
	   return used_mana;
   }

#if 1 ///~~~~~KNLG~~~~~{


//    template< bool skip_cap_regen = false >
//    void regenerate_mana( const manabar_params& params, uint32_t now )
//    {
//       params.validate();
// 
//       FC_ASSERT( now >= last_update_time );
//       uint32_t dt = now - last_update_time;
//       if( current_mana >= params.max_mana )
//       {
//          current_mana = params.max_mana;
//          last_update_time = now;
//          return;
//       }
// 
//       if( !skip_cap_regen )
//          dt = (dt > params.regen_time) ? params.regen_time : dt;
// 
//       uint128_t max_mana_dt = uint64_t( params.max_mana >= 0 ? params.max_mana : 0 );
//       max_mana_dt *= dt;
//       uint64_t u_regen = (max_mana_dt / params.regen_time).to_uint64();
//       FC_ASSERT( u_regen <= std::numeric_limits< int64_t >::max() );
//       int64_t new_current_mana = fc::signed_sat_add( current_mana, int64_t( u_regen ) );
//       current_mana = (new_current_mana > params.max_mana) ? params.max_mana : new_current_mana;
// 
//       last_update_time = now;
//    }
// 
//    template< bool skip_cap_regen = false >
//    void regenerate_mana( const manabar_params& params, fc::time_point_sec now )
//    {
//       regenerate_mana< skip_cap_regen >( params, now.sec_since_epoch() );
//    }
#endif ///~~~~~KNLG~~~~~}

   bool has_mana( int64_t mana_needed )const
   {
      return (mana_needed <= 0) || (current_mana >= mana_needed);
   }

   bool has_mana( uint64_t mana_needed )const
   {
      FC_ASSERT( mana_needed <= std::numeric_limits< int64_t >::max() );
      return has_mana( (int64_t) mana_needed );
   }

   void use_mana( int64_t mana_used, int64_t min_mana = std::numeric_limits< uint64_t >::min() )
   {
      current_mana = fc::signed_sat_sub( current_mana, mana_used );

      if( current_mana < min_mana )
      {
         current_mana = min_mana;
      }
   }

   void use_mana( uint64_t mana_used, int64_t min_mana = std::numeric_limits< uint64_t >::min() )
   {
      FC_ASSERT( mana_used <= std::numeric_limits< int64_t >::max() );
      use_mana( (int64_t) mana_used, min_mana );
   }
};

///~~~~~KNLG~~~~~{
//	template< typename T >
// int64_t get_effective_vesting_shares( const T& account )
// {
//    int64_t effective_vesting_shares =
//         account.vesting_shares.amount.value              // base vesting shares
//       + account.received_vesting_shares.amount.value     // incoming delegations
//       - account.delegated_vesting_shares.amount.value;   // outgoing delegations
// 
//    // If there is a power down occuring, also reduce effective vesting shares by this week's power down amount
//    if( account.next_vesting_withdrawal != fc::time_point_sec::maximum() )
//    {
//       effective_vesting_shares -=
//          std::min(
//             account.vesting_withdraw_rate.amount.value,           // Weekly amount
//             account.to_withdraw.value - account.withdrawn.value   // Or remainder
//             );
//    }
// 
//    return effective_vesting_shares;
// }
///~~~~~KNLG~~~~~}

} } } // knowledgr::chain::util

FC_REFLECT( knowledgr::chain::util::manabar,
   (current_mana)
   (last_update_time)
   )
