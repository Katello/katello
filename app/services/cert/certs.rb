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
      @ssl_client_key ||= OpenSSL::PKey.read(File.read(ssl_client_key_filename))
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

    # cert_mapping takes in a File and will return a hash with the key being an OID and the value being the human readable name.
    def self.cert_mapping(cert)
      certificate = OpenSSL::X509::Certificate.new(cert)
      subject_public_key_info = OpenSSL::ASN1.decode(
        certificate.public_key.public_to_der
      )

      algorithm_oid = subject_public_key_info.value.first.value.first

      { algorithm_oid.oid => algorithm_oid.ln }
    end

    # Returns available key algorithms using cert_mapping on the Candlepin CA certificate
    # and additional supported algorithms
    def self.available_key_algorithms
      algorithms = []
      sha256_with_rsa_oid = '1.2.840.113549.1.1.11'

      # Use cert_mapping on the Candlepin CA certificate to get the current algorithm
      begin
        candlepin_cert = File.read(backend_ca_cert_file(:candlepin))
        mapping = cert_mapping(candlepin_cert)
        key_oid = mapping.keys.first
        key_name = mapping.values.first

        # Determine signature algorithm: use SHA256WithRSA for RSA, same OID for PQC
        signature_oid = rsa_algorithm?(key_oid) ? sha256_with_rsa_oid : key_oid

        algorithms << {
          oid: key_oid,
          name: key_name,
          signature_oid: signature_oid,
        }
      rescue StandardError => e
        Rails.logger.warn("Could not read Candlepin certificate: #{e.message}")
      end
    end

    # Check if an algorithm OID represents an RSA algorithm
    def self.rsa_algorithm?(oid)
      rsa_oids = [
        '1.2.840.113549.1.1.1',  # rsaEncryption
        '1.2.840.113549.1.1.7',  # id-RSAES-OAEP
        '1.2.840.113549.1.1.10', # id-RSASSA-PSS
      ]
      rsa_oids.include?(oid)
    end
  end
end
