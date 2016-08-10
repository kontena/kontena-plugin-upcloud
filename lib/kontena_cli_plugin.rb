require 'kontena_cli'
require_relative 'kontena/plugin/upcloud'
require_relative 'kontena/plugin/upcloud_command'

Kontena::MainCommand.register("upcloud", "Upcloud specific commands", Kontena::Plugin::UpcloudCommand)
