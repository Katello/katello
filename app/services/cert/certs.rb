module Cert
  module Certs
    def self.ueber_cert(organization)
      organization.debug_cert
    end

    def self.ca_cert
      File.open(Setting[:ssl_ca_file], 'r').read
    end

    def self.ssl_client_cert
      @ssl_client_cert ||= OpenSSL::X509::Certificate.new(File.open(Setting['pulp_client_cert'], 'r').read)
    end

    def self.ssl_client_key
      @ssl_client_key ||= OpenSSL::PKey::RSA.new(File.open(Setting['pulp_client_key'], 'r').read)
    end

    def self.verify_ueber_cert(organization)
      ueber_cert = OpenSSL::X509::Certificate.new(self.ueber_cert(organization)[:cert])
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_file Setting[:ssl_ca_file]
      organization.regenerate_ueber_cert unless cert_store.verify ueber_cert
    end
  end
end
