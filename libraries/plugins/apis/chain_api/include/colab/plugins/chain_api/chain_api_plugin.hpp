#pragma once
#include <colab/plugins/chain/chain_plugin.hpp>
#include <colab/plugins/json_rpc/json_rpc_plugin.hpp>

#include <appbase/application.hpp>

#define COLAB_CHAIN_API_PLUGIN_NAME "chain_api"


namespace colab { namespace plugins { namespace chain {

using namespace appbase;

class chain_api_plugin : public plugin< chain_api_plugin >
{
public:
   APPBASE_PLUGIN_REQUIRES(
      (colab::plugins::chain::chain_plugin)
      (colab::plugins::json_rpc::json_rpc_plugin)
   )

   chain_api_plugin();
   virtual ~chain_api_plugin();

   static const std::string& name()
      { static std::string name = COLAB_CHAIN_API_PLUGIN_NAME; return name; }

   virtual void set_program_options( options_description& cli, options_description& cfg ) override;

   void plugin_initialize( const variables_map& options ) override;
   void plugin_startup() override;
   void plugin_shutdown() override;

public:
   std::shared_ptr< class chain_api > api;
};

} } } // colab::plugins::chain
