module Kontena::Plugin::Upcloud::Nodes
  class TerminateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "NAME", "Node name"
    option "--username", "USER", "Upcloud username", required: true
    option "--password", "PASS", "Upcloud password", required: true

    requires_current_master_token

    def execute
      require_relative '../../../machine/upcloud'
      grid = client.get("grids/#{current_grid}")
      destroyer = Kontena::Machine::Upcloud::NodeDestroyer.new(client, username, password)
      destroyer.run!(grid, name)
    end
  end
end
