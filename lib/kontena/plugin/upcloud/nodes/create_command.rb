require 'kontena/plugin/upcloud/prompts'

module Kontena::Plugin::Upcloud::Nodes
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "[NAME]", "Node name"

    include Kontena::Plugin::Upcloud::Prompts::Create

    option "--count", "COUNT", "How many nodes should be created"

    requires_current_master_token

    def execute
      require_relative '../../../machine/upcloud'

      abort_unless_api_access

      grid = fetch_grid
      provisioner = Kontena::Machine::Upcloud::NodeProvisioner.new(client, username, password)
      provisioner.run!(
        master_uri: api_url,
        grid_token: grid['token'],
        grid: current_grid,
        ssh_key: ssh_key,
        count: count,
        name: name,
        plan: plan,
        zone: zone,
        version: version
      )
    end

    # @param [String] id
    # @return [Hash]
    def fetch_grid
      client.get("grids/#{current_grid}")
    end

    def default_count
      prompt.ask('How many servers:', default: 1)
    end
  end
end
