require 'kontena/plugin/upcloud/prompts'

module Kontena::Plugin::Upcloud::Nodes
  class RestartCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    include Kontena::Plugin::Upcloud::Prompts::NodeName
    include Kontena::Plugin::Upcloud::Prompts::Common

    def execute
      require_api_url
      require_current_grid

      abort_unless_api_access

      require 'kontena/machine/upcloud'

      restarter = Kontena::Machine::Upcloud::NodeRestarter.new(username, password)
      restarter.run!(name)
    end
  end
end
