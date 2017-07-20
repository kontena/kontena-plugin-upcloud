module Kontena::Plugin::Upcloud::Nodes
  class RestartCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "NAME", "Node name"
    option "--username", "USER", "Upcloud username", required: true, environment_variable: 'UPCLOUD_USERNAME'
    option "--password", "PASS", "Upcloud password", required: true, environment_variable: 'UPCLOUD_PASSWORD'

    def execute
      require_api_url
      require_current_grid

      require 'kontena/machine/upcloud'

      restarter = Kontena::Machine::Upcloud::NodeRestarter.new(username, password)
      restarter.run!(name)
    end
  end
end
