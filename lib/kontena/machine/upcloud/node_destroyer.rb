module Kontena
  module Machine
    module Upcloud
      class NodeDestroyer
        include RandomName
        include UpcloudCommon
        include Kontena::Cli::ShellSpinner

        attr_reader :api_client, :username, :password

        # @param [Kontena::Client] api_client Kontena api client
        # @param [String] token Upcloud token
        def initialize(api_client, upcloud_username, upcloud_password)
          @api_client = api_client
          @username = upcloud_username
          @password = upcloud_password
        end

        def run!(grid, name)

          abort_unless_api_access

          servers = get('server')
          unless servers && servers.has_key?(:servers)
            abort('Upcloud API error')
          end

          server = servers[:servers][:server].find{|s| s[:hostname] == name}

          abort "Cannot find node #{name.colorize(:cyan)} in UpCloud" unless server

          server_data = get("server/#{server[:uuid]}")

          storage_devices = server_data.fetch(:server, {}).fetch(:storage_devices, {}).fetch(:storage_device, [])
          storage_uuids = storage_devices.map{|s| s[:storage]}

          abort('No storage devices found for UpCloud node') if storage_uuids.empty?

          if server
            unless server[:state].eql?('stopped')
              spinner "Shutting down UpCloud node #{name.colorize(:cyan)} " do
                device_data = post(
                  "server/#{server[:uuid]}/stop", body: {
                    stop_server: {
                      stop_type: 'soft',
                      timeout: 120
                    }
                  }.to_json
                )

                until device_data && device_data.fetch(:state, nil).to_s.eql?('stopped')
                  device_data = get("server/#{server[:uuid]}").fetch(:server, {}) rescue nil
                  sleep 5
                end
              end
            end

            spinner "Terminating UpCloud node #{name.colorize(:cyan)} " do
              response = delete("server/#{server[:uuid]}")
              abort "Cannot delete node #{name.colorize(:cyan)} in Upcloud" unless response[:success]
            end

            storage_uuids.each do |uuid|
              spinner "Deleting UpCloud storage device '#{uuid.colorize(:cyan)}' " do
                response = delete("storage/#{uuid}")
                unless response[:success]
                  puts "#{"WARNING".colorize(:red)}: Couldn't delete UpCloud storage '#{uuid.colorize(:cyan)}', check manually."
                end
              end
            end
          else
            abort "Cannot find node #{name.colorize(:cyan)} in UpCloud"
          end
          node = api_client.get("grids/#{grid['id']}/nodes")['nodes'].find{|n| n['name'] == name}
          if node
            spinner "Removing node #{name.colorize(:cyan)} from grid #{grid['name'].colorize(:cyan)} " do
              api_client.delete("grids/#{grid['id']}/nodes/#{name}")
            end
          end
        end
      end
    end
  end
end
