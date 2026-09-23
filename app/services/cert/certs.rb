module Cert
  module Certs
    SHA_256_WITH_RSA_SIGNATURE_OID = '1.2.840.113549.1.1.11'.freeze
    KEY_OID_TO_SIGNATURE_OID = {
      '1.2.840.113549.1.1.1' => SHA_256_WITH_RSA_SIGNATURE_OID,  # rsaEncryption
    }.freeze

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
      algorithms = Rails.cache.fetch('katello/available_key_algorithms', expires_in: 5.minutes, race_condition_ttl: 3.seconds, skip_nil: true) do
        result = []

        # Use cert_mapping on the Candlepin CA certificate to get the current algorithm(s)
        begin
          candlepin_cert = File.read(backend_ca_cert_file(:candlepin))
          mapping = cert_mapping(candlepin_cert)

          mapping.each do |key_oid, key_name|
            result << {
              oid: key_oid,
              name: key_name,
              signature_oid: KEY_OID_TO_SIGNATURE_OID.fetch(key_oid, key_oid),
            }
          end
          result
        rescue StandardError => e
          Rails.logger.warn("Could not read Candlepin certificate: #{e.message}")
          nil
        end
      end
      algorithms || []
    end
  end
end
