class Kontena::Plugin::UpcloudCommand < Kontena::Command
  subcommand 'master', 'Upcloud master related commands', load_subcommand('kontena/plugin/upcloud/master_command')
  subcommand 'node', 'Upcloud node related commands', load_subcommand('kontena/plugin/upcloud/node_command')
end
