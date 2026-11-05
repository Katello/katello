require 'openssl'

module Katello
  module PqcSupport
    # Call before any assertions or mocks that require the algorithm. Probe the
    # linked library so distro backports work regardless of the header version.
    # PQC CI sets PQC_REQUIRED=true to prevent silently skipping its coverage.
    def pqc_required(algorithm = 'ML-DSA-65')
      return if pqc_supported?(algorithm)

      message = "#{algorithm} is unavailable in #{OpenSSL::OPENSSL_LIBRARY_VERSION}"
      flunk message if ENV['PQC_REQUIRED'] == 'true'
      skip message
    end

    private

    def pqc_supported?(algorithm)
      return false unless OpenSSL::PKey.respond_to?(:generate_key)

      OpenSSL::PKey.generate_key(algorithm)
      OpenSSL::ASN1::ObjectId.new(algorithm).ln == algorithm
    rescue OpenSSL::PKey::PKeyError, OpenSSL::ASN1::ASN1Error
      false
    end
  end
end
