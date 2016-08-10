require_relative 'nodes/create_command'
require_relative 'nodes/restart_command'
require_relative 'nodes/terminate_command'

class Kontena::Plugin::Upcloud::NodeCommand < Kontena::Command

  subcommand "create", "Create a new node to Upcloud", Kontena::Plugin::Upcloud::Nodes::CreateCommand
  subcommand "restart", "Restart Upcloud node", Kontena::Plugin::Upcloud::Nodes::RestartCommand
  subcommand "terminate", "Terminate Upcloud node", Kontena::Plugin::Upcloud::Nodes::TerminateCommand

  def execute
  end
end
