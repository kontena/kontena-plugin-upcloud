module Kontena::Plugin::Upcloud::Nodes
  class TerminateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "[NAME]", "Node name"
    option "--username", "USER", "Upcloud username", required: true, environment_variable: 'UPCLOUD_USERNAME'
    option "--password", "PASS", "Upcloud password", required: true, environment_variable: 'UPCLOUD_PASSWORD'

    option  '--force', :flag, "Force terminate", attribute_name: :forced

    requires_current_master_token

    def execute
      require_relative '../../../machine/upcloud'
      confirm_command(name) unless forced?
      grid = client.get("grids/#{current_grid}")
      destroyer = Kontena::Machine::Upcloud::NodeDestroyer.new(client, username, password)
      destroyer.run!(grid, name)
    end

    def default_username
      prompt.ask('UpCloud username:', echo: true)
    end

    def default_password
      prompt.ask('UpCloud password:', echo: false)
    end

    def default_name
      nodes = client.get("grids/#{current_grid}/nodes")
      nodes = nodes['nodes'].select{ |n|
        n['labels'] && n['labels'].include?('provider=upcloud'.freeze)
      }
      raise "Did not find any nodes with label provider=upcloud" if nodes.size == 0
      prompt.select("Select node: ") do |menu|
        nodes.sort_by{|n| n['node_number'] }.reverse.each do |node|
          initial = node['initial_member'] ? '(initial) ' : ''
          menu.choice "#{node['name']} #{initial}", node['name']
        end
      end
    end
  end
end
