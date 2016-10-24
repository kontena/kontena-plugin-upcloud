require 'fileutils'
require 'erb'
require 'open3'
require 'json'

module Kontena
  module Machine
    module Upcloud
      class MasterProvisioner
        include RandomName
        include Machine::CertHelper
        include UpcloudCommon
        include Kontena::Cli::Common

        attr_reader :http_client, :username, :password

        # @param [String] token Upcloud token
        def initialize(upcloud_username, upcloud_password)
          @username = upcloud_username
          @password = upcloud_password
        end

        def run!(opts)
          if File.readable?(File.expand_path(opts[:ssh_key]))
            ssh_key = File.read(File.expand_path(opts[:ssh_key])).strip
          end

          abort('Invalid ssh key') unless ssh_key && ssh_key.start_with?('ssh-')

          if opts[:ssl_cert]
            abort('Invalid ssl cert') unless File.exists?(File.expand_path(opts[:ssl_cert]))
            ssl_cert = File.read(File.expand_path(opts[:ssl_cert]))
          else
            spinner "Generating a self-signed SSL certificate" do
              ssl_cert = generate_self_signed_cert
            end
          end

          abort_unless_api_access

          abort('CoreOS template not found on Upcloud') unless coreos_template = find_template('CoreOS Stable')
          abort('Server plan not found on Upcloud') unless plan = find_plan(opts[:plan])
          abort('Zone not found on Upcloud') unless zone_exist?(opts[:zone])

          if opts[:name]
            server_name = opts[:name]
            hostname = opts[:name].start_with?('kontena-master') ? opts[:name] : "kontena-master-#{opts[:name]}"
          else
            hostname = generate_name
            server_name = hostname.sub('kontena-master-', '')
          end

          server_name = opts[:name] 
          hostname = opts[:name] || generate_name

          userdata_vars = opts.merge(
              ssl_cert: ssl_cert,
              server_name: server_name
          )

          device_data = {
            server: {
              zone: opts[:zone],
              title: "Kontena Master #{server_name}",
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
                  ssh_key: [ssh_key]
                }
              }
            }
          }.to_json

          spinner "Creating an Upcloud server #{hostname.colorize(:cyan)} " do
            response = post('server', body: device_data)
            if response.has_key?(:error)
              abort("\nUpcloud server creation failed (#{response[:error].fetch(:error_message, '')})")
            end
            device_data = response[:server]

            until device_data && device_data.fetch(:state, nil).to_s == 'maintenance'
              device_data = get("server/#{device[:uuid]}").fetch(:server, {}) rescue nil
              sleep 5
            end
          end

          device_public_ip = device_data[:ip_addresses][:ip_address].find do |ip|
            ip[:access].eql?('public') && ip[:family].eql?('IPv4')
          end

          abort('Server public ip not found, destroy manually.') unless device_public_ip

          master_url = "https://#{device_public_ip[:address]}"
          Excon.defaults[:ssl_verify_peer] = false
          @http_client = Excon.new("#{master_url}", :connect_timeout => 10)

          spinner "Waiting for #{hostname.colorize(:cyan)} to start" do
            sleep 1 until master_running?
          end

          master_version = nil
          spinner "Retrieving Kontena Master version" do
            master_version = JSON.parse(@http_client.get(path: '/').body)["version"] rescue nil
          end

          spinner "Kontena Master #{master_version} is now running at #{master_url}"

          {
            name: server_name,
            public_ip: device_public_ip[:address],
            provider: 'upcloud',
            version: master_version,
            code: opts[:initial_admin_code]
          }
        end

        def user_data(vars)
          cloudinit_template = File.join(__dir__ , '/cloudinit_master.yml')
          erb(File.read(cloudinit_template), vars)
        end

        def generate_name
          "kontena-master-#{super}-#{rand(1..9)}"
        end

        def master_running?
          http_client.get(path: '/').status == 200
        rescue
          false
        end

        def erb(template, vars)
          ERB.new(template, nil, '%<>-').result(OpenStruct.new(vars).instance_eval { binding })
        end
      end
    end
  end
end
