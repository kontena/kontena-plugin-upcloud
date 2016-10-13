require 'securerandom'

module Kontena::Plugin::Upcloud::Master
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common

    option "--name", "[NAME]", "Set Kontena Master name"
    option "--username", "USER", "Upcloud username", required: true
    option "--password", "PASS", "Upcloud password", required: true
    option "--ssh-key", "SSH_KEY", "Path to ssh public key", required: true
    option "--ssl-cert", "SSL CERT", "SSL certificate file (optional)"
    option "--plan", "PLAN", "Server plan", default: '1xCPU-1GB'
    option "--zone", "ZONE", "Zone", default: 'fi-hel1'
    option "--vault-secret", "VAULT_SECRET", "Secret key for Vault (optional)"
    option "--vault-iv", "VAULT_IV", "Initialization vector for Vault (optional)"
    option "--mongodb-uri", "URI", "External MongoDB uri (optional)"
    option "--version", "VERSION", "Define installed Kontena version", default: 'latest'

    def execute

      require_relative '../../../machine/upcloud'

      provisioner = Kontena::Machine::Upcloud::MasterProvisioner.new(username, password)
      provisioner.run!(
          name: self.name,
          ssh_key: ssh_key,
          ssl_cert: ssl_cert,
          plan: plan,
          zone: zone,
          version: version,
          vault_secret: vault_secret || SecureRandom.hex(24),
          vault_iv: vault_iv || SecureRandom.hex(24),
          initial_admin_code: SecureRandom.hex(16),
          mongodb_uri: mongodb_uri
      )
    end

  end
end
