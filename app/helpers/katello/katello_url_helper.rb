module Katello
  module KatelloUrlHelper
    unless defined? CONSTANTS_DEFINED
      FILEPREFIX = 'file'
      PROTOCOLS = ['http', 'https', 'ftp', FILEPREFIX]

      CONSTANTS_DEFINED = true
    end

    def kurl_valid?(url)
      validate_host(url) && validate_scheme(url, PROTOCOLS)
    end

    def file_prefix?(url)
      validate_scheme(url, [FILEPREFIX])
    end

    private

    def validate_host(url)
      URI.parse(url).host.present?
    rescue URI::InvalidURIError
      return false
    end

    def validate_scheme(url, prefixes)
      return false if (scheme = URI.parse(url).scheme).blank?
      prefixes.include?(scheme.downcase)
    rescue URI::InvalidURIError
      return false
    end
  end
end
