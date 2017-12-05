require 'fileutils'
require 'erb'
require 'open3'

module Kontena
  module Machine
    module Upcloud
      class NodeProvisioner
        include RandomName
        include Kontena::Cli::ShellSpinner

        attr_reader :api_client, :uc_client

        # @param [Kontena::Client] api_client Kontena api client
        # @param [String] upcloud_username Upcloud username
        # @param [String] upcloud_password Upcloud password
        def initialize(api_client, upcloud_username, upcloud_password)
          @api_client = api_client
          @uc_client = Kontena::Machine::Upcloud::Client.new(upcloud_username, upcloud_password)
        end

        def run!(opts)
          abort('Invalid ssh key') unless opts[:ssh_key].to_s.start_with?('ssh-')

          count = opts[:count].to_i
          userdata_vars = {
            version: opts[:version],
            master_uri: opts[:master_uri],
            grid_token: opts[:grid_token],
          }

          abort('CoreOS template not found on Upcloud') unless coreos_template = uc_client.find_template('CoreOS Stable')
          abort('Server plan not found on Upcloud') unless plan = uc_client.find_plan(opts[:plan])
          abort('Zone not found on Upcloud') unless uc_client.zone_exist?(opts[:zone])

          count.times do |i|
            if opts[:name]
              hostname = count == 1 ? opts[:name] : "#{opts[:name]}-#{i + 1}"
            else
              hostname = generate_name
            end
            device_data = {
              server: {
                zone: opts[:zone],
                title: "#{opts[:grid]}/#{hostname}",
                hostname: hostname,
                plan: plan[:name],
                vnc: 'off',
                timezone: 'UTC',
                user_data: user_data(userdata_vars),
                firewall: 'off',
                storage_devices: {
                  storage_device: [
                    {
                      action: 'clone',
                      storage: coreos_template[:uuid],
                      title: "From template #{coreos_template[:title]}",
                      size: plan[:storage_size],
                      tier: 'maxiops'
                    }
                  ]
                },
                login_user: {
                  create_password: 'no',
                  username: 'root',
                  ssh_keys: {
                    ssh_key: [opts[:ssh_key]]
                  }
                }
              }
            }.to_json

            spinner "Creating UpCloud node #{hostname.colorize(:cyan)} " do
              response = uc_client.post('server', device_data)

              if response.has_key?(:error)
                abort("\nUpCloud server creation failed (#{response[:error].fetch(:error_message, '')})")
              end
              device_data = response[:server]

              until device_data && device_data.fetch(:state, nil).to_s == 'maintenance'
                device_data = uc_client.get("server/#{device[:uuid]}").fetch(:server, {}) rescue nil
                sleep 5
              end
            end

            node = nil
            spinner "Waiting for node #{hostname.colorize(:cyan)} join to grid #{opts[:grid].colorize(:cyan)} " do
              sleep 2 until node = node_exists_in_grid?(opts[:grid], hostname)
            end
            set_labels(node, ["region=#{opts[:zone]}", "provider=upcloud"])
          end
        end

        def user_data(vars)
          cloudinit_template = File.join(__dir__ , '/cloudinit.yml')
          erb(File.read(cloudinit_template), vars)
        end

        def generate_name
          "#{super}-#{rand(1..99)}"
        end

        def node_exists_in_grid?(grid, hostname)
          api_client.get("grids/#{grid}/nodes")['nodes'].find{|n| n['name'] == hostname}
        end

        def erb(template, vars)
          ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
        end

        # @param [Hash] node
        # @param [Array<String>] labels
        def set_labels(node, labels)
          data = {}
          data[:labels] = labels
          api_client.put("nodes/#{node['id']}", data)
        end
      end
    end
  end
end
