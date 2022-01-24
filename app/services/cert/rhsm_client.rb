require 'openssl'
require 'base64'

module Cert
  class RhsmClient
    attr_accessor :cert

    def initialize(cert)
      self.cert = extract(cert)
    end

    def uuid
      @uuid ||= @cert.subject.to_a.detect { |name, _, _| name == 'CN' }&.second
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

    def strip_cert(cert)
      cert = cert.to_s.gsub("-----BEGIN CERTIFICATE-----", "").gsub("-----END CERTIFICATE-----", "")
      cert.delete!(' ')
      cert.gsub!(/\n/, '')
      cert
    end
  end
end
