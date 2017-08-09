module Kontena
  module Machine
    module Upcloud
      class NodeRestarter
        include RandomName
        include Kontena::Cli::ShellSpinner

        attr_reader :uc_client

        # @param [String] upcloud_username Upcloud username
        # @param [String] upcloud_password Upcloud password
        def initialize(upcloud_username, upcloud_password)
          @uc_client = Kontena::Machine::Upcloud::Client.new(upcloud_username, upcloud_password)
        end

        def run!(name)

          servers = uc_client.get('server')
          unless servers && servers.has_key?(:servers)
            abort('Upcloud API error')
          end

          server = servers[:servers][:server].find{|s| s[:hostname] == name}

          if server
            spinner "Restarting UpCloud node #{name.colorize(:cyan)} " do
              result = uc_client.post(
                "server/#{server[:uuid]}/restart", {
                  restart_server: {
                    stop_type: 'soft',
                    timeout: 600,
                    timeout_action: 'destroy' # hard shutdown in case sof timeouts
                  }
                }.to_json
              )
            end
          else
            abort "Cannot find node #{name.colorize(:cyan)} in UpCloud"
          end
        end
      end
    end
  end
end
