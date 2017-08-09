require 'kontena/machine/upcloud/client'

module Kontena
  module Plugin
    module Upcloud
      module Prompts
        module Common
          def self.included(base)
            base.prepend Defaults
            base.option "--username", "USER", "Upcloud username", required: true, environment_variable: 'UPCLOUD_USERNAME'
            base.option "--password", "PASS", "Upcloud password", required: true, environment_variable: 'UPCLOUD_PASSWORD'
          end

          def upcloud_client
            @upcloud_client ||=  Kontena::Machine::Upcloud::Client.new(username, password)
          end

          def abort_unless_api_access
            unless upcloud_client.api_access?
              exit_with_error('Upcloud API authentication failed. Check that API access is enabled for the user.')
            end
          end

          module Defaults
            def default_username
              prompt.ask('UpCloud username:', echo: true)
            end

            def default_password
              pass = prompt.ask('UpCloud password:', echo: false)
            end
          end
        end

        module NodeName
          def self.included(base)
            base.prepend Defaults
            base.parameter "[NAME]", "Node name"
          end

          module Defaults
            def default_name
              nodes = client.get("grids/#{current_grid}/nodes")
              nodes = nodes['nodes'].select{ |n|
                n['labels'] && n['labels'].include?('provider=upcloud'.freeze)
              }
              raise "Did not find any nodes with label provider=upcloud" if nodes.empty?
              prompt.select("Select node:") do |menu|
                nodes.sort_by{|n| n['node_number'] }.reverse.each do |node|
                  initial = node['initial_member'] ? '(initial) ' : ''
                  menu.choice "#{node['name']} #{initial}", node['name']
                end
              end
            end
          end
        end

        module Create
          def self.included(base)
            base.include Common
            base.prepend Defaults
            base.option "--ssh-key", "SSH_KEY", "Path to ssh public key", attribute_name: :ssh_key_path
            base.option "--version", "VERSION", "Define installed Kontena version", default: 'latest'
            base.option "--zone", "ZONE", "Zone", required: true
            base.option "--plan", "PLAN", "Server size", required: true
          end

          def ssh_key
            return File.read(ssh_key_path) unless ssh_key_path.nil?
            default = File.read(Defaults::DEFAULT_SSH_KEY_PATH).strip rescue nil
            prompt.ask('SSH public key: (enter an ssh key in OpenSSH format "ssh-xxx xxxxx key_name")', default: default) do |q|
              q.validate /^ssh-rsa \S+ \S+$/
            end
          end

          module Defaults
            DEFAULT_SSH_KEY_PATH = File.join(Dir.home, '.ssh', 'id_rsa.pub')

            def default_plan
              prompt.select("Choose plan:") do |menu|
                upcloud_client.list_plans.each do |plan|
                  menu.choice "#{plan[:name]} (#{plan[:memory_amount]}MB #{plan[:storage_size]}GB #{plan[:storage_tier]})", plan[:name]
                end
              end
            end

            def default_zone
              prompt.select("Choose availability zone:") do |menu|
                upcloud_client.list_zones.each do |zone|
                  menu.choice zone[:description], zone[:id]
                end
              end
            end
          end
        end
      end
    end
  end
end
