require_relative 'master/create_command'

class Kontena::Plugin::Upcloud::MasterCommand < Kontena::Command

  subcommand "create", "Create a new master to Upcloud", Kontena::Plugin::Upcloud::Master::CreateCommand

  def execute
  end
end
