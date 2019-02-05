#pragma once

#include <knowledgr/protocol/types.hpp>

#include <knowledgr/plugins/block_data_export/exportable_block_data.hpp>
#include <knowledgr/plugins/rc/resource_count.hpp>

#include <fc/int_array.hpp>

#include <vector>

namespace knowledgr { namespace plugins { namespace rc {

using knowledgr::plugins::block_data_export::exportable_block_data;
using knowledgr::protocol::account_name_type;

struct rc_transaction_info
{
   account_name_type         resource_user;
   count_resources_result    usage;
   fc::int_array< int64_t, KNOWLEDGR_NUM_RESOURCE_TYPES >
                             cost;
};

typedef rc_transaction_info rc_optional_action_info;

struct rc_block_info
{
   resource_count_type       dt;
   resource_count_type       decay;
   resource_count_type       budget;
   resource_count_type       usage;
   resource_count_type       adjustment;
   resource_count_type       pool;
};

struct exp_rc_data
   : public exportable_block_data
{
   exp_rc_data();
   virtual ~exp_rc_data();

   virtual void to_variant( fc::variant& v )const override;

   rc_block_info                          block_info;
   std::vector< rc_transaction_info >     tx_info;
   std::vector< rc_optional_action_info > opt_action_info;
};

} } } // knowledgr::plugins::rc

FC_REFLECT( knowledgr::plugins::rc::rc_transaction_info,
   (resource_user)
   (usage)
   (cost)
)

FC_REFLECT( knowledgr::plugins::rc::rc_block_info,
   (dt)
   (decay)
   (budget)
   (usage)
   (adjustment)
   (pool)
)

FC_REFLECT( knowledgr::plugins::rc::exp_rc_data,
   (block_info)
   (tx_info)
   (opt_action_info)
)