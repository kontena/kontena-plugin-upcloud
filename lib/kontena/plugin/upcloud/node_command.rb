class Kontena::Plugin::Upcloud::NodeCommand < Kontena::Command
  subcommand "create", "Create a new node to Upcloud", load_subcommand('kontena/plugin/upcloud/nodes/create_command')
  subcommand "restart", "Restart Upcloud node", load_subcommand('kontena/plugin/upcloud/nodes/restart_command')
  subcommand "terminate", "Terminate Upcloud node", load_subcommand('kontena/plugin/upcloud/nodes/terminate_command')
end
