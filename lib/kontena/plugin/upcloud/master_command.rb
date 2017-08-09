class Kontena::Plugin::Upcloud::MasterCommand < Kontena::Command
  subcommand "create", "Create a new master to Upcloud", load_subcommand('kontena/plugin/upcloud/master/create_command')
end
