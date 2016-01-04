require 'openssl'
require 'base64'

module Client
  class Cert
    attr_accessor :cert

    def initialize(cert)
      self.cert = extract(cert)
    end

    def uuid
      drop_cn_prefix_from_subject(@cert.subject.to_s)
    end

    private

    def extract(cert)
      if cert.empty?
        fail('Invalid cert provided. Ensure that the provided cert is not empty.')
      else
        cert = strip_cert(cert)
        cert = Base64.decode64(cert)

        OpenSSL::X509::Certificate.new(cert)
      end
    end

    def drop_cn_prefix_from_subject(subject_string)
      subject_string.sub(/\/CN=/i, '')
    end

    def strip_cert(cert)
      cert = cert.to_s.gsub("-----BEGIN CERTIFICATE-----", "").gsub("-----END CERTIFICATE-----", "")
      cert.delete!(' ')
      cert.gsub!(/\n/, '')
      cert
    end
  end
end
