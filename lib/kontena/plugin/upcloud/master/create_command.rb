require 'securerandom'
require 'kontena/plugin/upcloud/prompts'

module Kontena::Plugin::Upcloud::Master
  class CreateCommand < Kontena::Command
    include Kontena::Cli::Common

    option "--name", "[NAME]", "Set Kontena Master name"

    include Kontena::Plugin::Upcloud::Prompts::Create

    option "--ssl-cert", "SSL CERT", "SSL certificate file (optional)"
    option "--vault-secret", "VAULT_SECRET", "Secret key for Vault (optional)"
    option "--vault-iv", "VAULT_IV", "Initialization vector for Vault (optional)"
    option "--mongodb-uri", "URI", "External MongoDB uri (optional)"

    def execute
      require_relative '../../../machine/upcloud'

      abort_unless_api_access

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
  end
end
