module Kontena::Plugin::Upcloud::Nodes
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common
    include Kontena::Cli::GridOptions

    parameter "[NAME]", "Node name"
    option "--username", "USER", "Upcloud username", required: true
    option "--password", "PASS", "Upcloud password", required: true
    option "--ssh-key", "SSH_KEY", "Path to ssh public key", required: true
    option "--plan", "PLAN", "Server size", default: '1xCPU-1GB'
    option "--zone", "ZONE", "Zone", default: 'fi-hel1'
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

  end
end
