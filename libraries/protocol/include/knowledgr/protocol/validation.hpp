
#pragma once

#include <knowledgr/protocol/base.hpp>
#include <knowledgr/protocol/block_header.hpp>
#include <knowledgr/protocol/asset.hpp>

#include <fc/utf8.hpp>

namespace knowledgr { namespace protocol {

inline bool is_asset_type( asset asset, asset_symbol_type symbol )
{
   return asset.symbol == symbol;
}

inline void validate_account_name( const string& name )
{
   FC_ASSERT( is_valid_account_name( name ), "Account name ${n} is invalid", ("n", name) );
}

inline void validate_permlink( const string& permlink )
{
   FC_ASSERT( permlink.size() < KNOWLEDGR_MAX_PERMLINK_LENGTH, "permlink is too long" );
   FC_ASSERT( fc::is_utf8( permlink ), "permlink not formatted in UTF8" );
}

} }
