module Katello
  module KatelloUrlHelper
    unless defined? CONSTANTS_DEFINED
      FILEPREFIX = 'file'
      PROTOCOLS = ['http', 'https', 'ftp', FILEPREFIX]

      CONSTANTS_DEFINED = true
    end

    def kurl_valid?(url)
      valid_for_prefixes(url, PROTOCOLS)
    end

    def file_prefix?(url)
      valid_for_prefixes(url, [FILEPREFIX])
    end

    private

    def valid_for_prefixes(url, prefixes)
      return false unless (scheme = URI.parse(url).scheme).present?
      prefixes.include?(scheme.downcase)
    rescue URI::InvalidURIError
      return false
    end
  end
end
