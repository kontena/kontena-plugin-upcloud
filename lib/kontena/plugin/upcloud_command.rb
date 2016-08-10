require_relative 'upcloud/master_command'
require_relative 'upcloud/node_command'

class Kontena::Plugin::UpcloudCommand < Kontena::Command

  subcommand 'master', 'Upcloud master related commands', Kontena::Plugin::Upcloud::MasterCommand
  subcommand 'node', 'Upcloud node related commands', Kontena::Plugin::Upcloud::NodeCommand

  def execute
  end
end
