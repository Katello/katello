module Cert
  module Certs
    def self.ueber_cert(organization)
      organization.debug_cert
    end

    def self.ca_cert
      File.read(Setting[:ssl_ca_file])
    end

    def self.candlepin_client_ca_cert
      File.read(SETTINGS[:katello][:candlepin][:ca_cert_file])
    end

    def self.ssl_client_cert(use_admin_as_cn_cert: false)
      @ssl_client_cert ||= OpenSSL::X509::Certificate.new(File.read(ssl_client_cert_filename(use_admin_as_cn_cert: use_admin_as_cn_cert)))
    end

    def self.ssl_client_cert_filename(use_admin_as_cn_cert: false)
      if use_admin_as_cn_cert
        Setting[:pulp_client_cert]
      else
        Setting[:ssl_certificate]
      end
    end

    def self.ssl_client_key(use_admin_as_cn_cert: false)
      @ssl_client_key ||= OpenSSL::PKey::RSA.new(File.read(ssl_client_key_filename(use_admin_as_cn_cert: use_admin_as_cn_cert)))
    end

    def self.ssl_client_key_filename(use_admin_as_cn_cert: false)
      if use_admin_as_cn_cert
        Setting[:pulp_client_key]
      else
        Setting[:ssl_priv_key]
      end
    end

    def self.verify_ueber_cert(organization)
      ueber_cert = OpenSSL::X509::Certificate.new(self.ueber_cert(organization)[:cert])
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_file SETTINGS[:katello][:candlepin][:ca_cert_file]
      organization.regenerate_ueber_cert unless cert_store.verify ueber_cert
    end
  end
end
