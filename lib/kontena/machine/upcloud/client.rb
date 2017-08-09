require 'excon'
require 'json'

module Kontena
  module Machine
    module Upcloud
      class Client

        API_URL = 'https://api.upcloud.com'.freeze
        ACCEPT = 'Accept'.freeze
        CTYPE = 'Content-Type'.freeze
        APP_JSON = 'application/json'.freeze
        CTYPE_HEAD = { CTYPE => APP_JSON }

        attr_reader :http_client

        def initialize(username, password)
          @http_client = Excon.new(
            API_URL,
            omit_default_port: true,
            user: username,
            password: password,
          )
        end

        def get(path)
          request(method: :get, path: path)
        end

        def post(path, body)
          request(method: :post, path: path, body: body, headers: CTYPE_HEAD)
        end

        def delete(path)
          request(method: :delete, path: path)
        end

        def find_template(name)
          get('storage/template')[:storages][:storage].find{|s| s[:title].downcase.start_with?(name.downcase)}
        end

        def find_plan(name)
          list_plans.find{|s| s[:name].downcase.eql?(name.downcase)}
        end

        def list_plans
          get('plan')[:plans][:plan]
        end

        def list_zones
          get('zone')[:zones][:zone]
        end

        def zone_exist?(name)
          list_zones.any? { |zone| zone[:id] == name }
        end

        def get_server(id)
          get("server/#{id}").fetch(:server, nil)
        end

        def api_access?
          response = get('account')
          response.kind_of?(Hash) && response.has_key?(:account)
        rescue
          false
        end

        private

        def request(opts)
          response = http_client.request(
            opts.merge(
              path: "/1.2/#{opts[:path]}",
              headers: (opts[:headers] || {}).merge(ACCEPT => APP_JSON),
            )
          )

          if (200..299).cover?(response.status)
            if response.body && response.body.start_with?('{'.freeze)
              JSON.parse(response.body, symbolize_names: true)
            else
              { success: true }
            end
          else
            raise "Request to Upcloud failed: #{response.status} #{response.body}"
          end
        end
      end
    end
  end
end
