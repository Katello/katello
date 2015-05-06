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
      prefixes.include?(URI.parse(url).scheme)
    rescue URI::InvalidURIError
      return false
    end
  end
end
