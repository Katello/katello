module Katello
  module KatelloUrlHelper
    unless defined? CONSTANTS_DEFINED
      FILEPREFIX = ['file']
      PROTOCOLS = ['http', 'https', 'ftp']

      CONSTANTS_DEFINED = true
    end

    def kurl_valid?(url)
      return false if (scheme = URI.parse(url).scheme).blank?
      return true if FILEPREFIX.include?(scheme.downcase)
      URI.parse(url).host.present? && PROTOCOLS.include?(scheme.downcase)
    rescue URI::InvalidURIError
      return false
    end

  end
end
