module Cert
  module Certs
    def self.ueber_cert(organization)
      organization.debug_cert
    end

    def self.ca_cert
      File.read(Setting[:ssl_ca_file])
    end

    def self.candlepin_client_ca_cert
      File.read(backend_ca_cert_file(:candlepin))
    end

    def self.ssl_client_cert
      @ssl_client_cert ||= OpenSSL::X509::Certificate.new(File.read(ssl_client_cert_filename))
    end

    def self.ssl_client_cert_filename
      Setting[:ssl_certificate]
    end

    def self.ssl_client_key
      @ssl_client_key ||= OpenSSL::PKey::RSA.new(File.read(ssl_client_key_filename))
    end

    def self.ssl_client_key_filename
      Setting[:ssl_priv_key]
    end

    def self.backend_ca_cert_file(backend)
      SETTINGS.dig(:katello, backend, :ca_cert_file) || Setting[:ssl_ca_file]
    end

    def self.verify_ueber_cert(organization)
      ueber_cert = OpenSSL::X509::Certificate.new(self.ueber_cert(organization)[:cert])
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_file backend_ca_cert_file(:candlepin)
      organization.regenerate_ueber_cert unless cert_store.verify ueber_cert
    end
  end
end
