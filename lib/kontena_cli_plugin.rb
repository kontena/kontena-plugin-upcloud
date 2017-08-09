require 'kontena_cli'
require 'kontena/plugin/upcloud'
require 'kontena/cli/subcommand_loader'

Kontena::MainCommand.register("upcloud", "Upcloud specific commands", Kontena::Cli::SubcommandLoader.new('kontena/plugin/upcloud_command'))
