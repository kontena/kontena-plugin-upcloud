module Kontena::Plugin::Upcloud::Nodes
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "[NAME]", "Node name"
    option "--username", "USER", "Upcloud username", required: true, environment_variable: 'UPCLOUD_USERNAME'
    option "--password", "PASS", "Upcloud password", required: true, environment_variable: 'UPCLOUD_PASSWORD'
    option "--ssh-key", "SSH_KEY", "Path to ssh public key", default: '~/.ssh/id_rsa.pub'
    option "--zone", "ZONE", "Zone", required: true
    option "--plan", "PLAN", "Server size", required: true
    option "--version", "VERSION", "Define installed Kontena version", default: 'latest'

    requires_current_master_token

    def execute
      require_relative '../../../machine/upcloud'
      grid = fetch_grid
      provisioner = Kontena::Machine::Upcloud::NodeProvisioner.new(client, username, password)
      provisioner.run!(
        master_uri: api_url,
        grid_token: grid['token'],
        grid: current_grid,
        ssh_key: ssh_key,
        name: name,
        plan: plan,
        zone: zone,
        version: version
      )
    end

    # @param [String] id
    # @return [Hash]
    def fetch_grid
      client.get("grids/#{current_grid}")
    end


    def default_username
      prompt.ask('UpCloud username:', echo: true)
    end

    def default_password
      prompt.ask('UpCloud password:', echo: false)
    end

    def default_plan
      prompt.select("Choose plan:") do |menu|
        Kontena::Plugin::Upcloud::PLANS.each do |plan, name|
          menu.choice name, plan
        end
      end
    end

    def default_zone
      prompt.select("Choose availability zone:") do |menu|
        Kontena::Plugin::Upcloud::ZONES.each do |zone, name|
          menu.choice name, zone
        end
      end
    end
  end
end
