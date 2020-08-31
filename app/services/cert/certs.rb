module Cert
  module Certs
    def self.ueber_cert(organization)
      organization.debug_cert
    end

    def self.ca_cert
      File.open(Setting[:ssl_ca_file], 'r').read
    end

    def self.ssl_client_cert
      @ssl_client_cert ||= OpenSSL::X509::Certificate.new(File.open(ssl_client_cert_filename, 'r').read)
    end

    def self.ssl_client_cert_filename
      Setting['pulp_client_cert']
    end

    def self.ssl_client_key
      @ssl_client_key ||= OpenSSL::PKey::RSA.new(File.open(ssl_client_key_filename, 'r').read)
    end

    def self.ssl_client_key_filename
      Setting['pulp_client_key']
    end

    def self.verify_ueber_cert(organization)
      ueber_cert = OpenSSL::X509::Certificate.new(self.ueber_cert(organization)[:cert])
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_file SETTINGS[:katello][:candlepin][:ca_cert_file]
      organization.regenerate_ueber_cert unless cert_store.verify ueber_cert
    end
  end
end
