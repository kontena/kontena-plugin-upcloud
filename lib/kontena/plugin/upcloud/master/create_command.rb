require 'securerandom'

module Kontena::Plugin::Upcloud::Master
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common

    option "--name", "[NAME]", "Set Kontena Master name"
    option "--username", "USER", "Upcloud username", required: true, environment_variable: 'UPCLOUD_USERNAME'
    option "--password", "PASS", "Upcloud password", required: true, environment_variable: 'UPCLOUD_PASSWORD'
    option "--ssh-key", "SSH_KEY", "Path to ssh public key", default: '~/.ssh/id_rsa.pub'
    option "--ssl-cert", "SSL CERT", "SSL certificate file (optional)"
    option "--plan", "PLAN", "Server plan", required: true
    option "--zone", "ZONE", "Zone", required: true
    option "--vault-secret", "VAULT_SECRET", "Secret key for Vault (optional)"
    option "--vault-iv", "VAULT_IV", "Initialization vector for Vault (optional)"
    option "--mongodb-uri", "URI", "External MongoDB uri (optional)"
    option "--version", "VERSION", "Define installed Kontena version", default: 'latest'

    def execute
      require_relative '../../../machine/upcloud'

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

    def provisioner
      Kontena::Machine::Upcloud::MasterProvisioner.new(username, password)
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
