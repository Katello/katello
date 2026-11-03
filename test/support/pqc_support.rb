require 'openssl'

module Katello
  module PqcSupport
    # Call before any assertions or mocks that require the algorithm. Probe the
    # linked library so distro backports work regardless of the header version.
    # PQC CI sets PQC_REQUIRED=true to prevent silently skipping its coverage.
    def pqc_required(algorithm = 'ML-DSA-65')
      begin
        OpenSSL::PKey.generate_key(algorithm)
        supported = OpenSSL::ASN1::ObjectId.new(algorithm).ln == algorithm
      rescue OpenSSL::PKey::PKeyError, OpenSSL::ASN1::ASN1Error
        supported = false
      end
      return if supported

      message = "#{algorithm} is unavailable in #{OpenSSL::OPENSSL_LIBRARY_VERSION}"
      flunk message if ENV['PQC_REQUIRED'] == 'true'
      skip message
    end
  end
end
