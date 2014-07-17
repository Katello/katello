#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  require 'uri'
  module KatelloUrlHelper
    include Rails.application.routes.url_helpers

    unless defined? CONSTANTS_DEFINED
      PORT = /(([:]\d{1,5})?)/
      PROTOCOLS = %r{(https?|ftp)://}ix
      FILEPREFIX = %r{(^file://)|^/}ix # is this a file based url
      # validation of hostname according to RFC952 and RFC1123
      DOMAIN = /(?:(?:(?:(?:[a-z0-9][-a-z0-9]{0,61})?[a-z0-9])[.])*(?:[a-z][-a-z0-9]{0,61}[a-z0-9]|[a-z])[.]?)/
      IPV4 = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
      IPV4_ONLY = /^[0-2][0-5][0-5]\.[0-2][0-5][0-5]\.[0-2][0-5][0-5]\.[0-2][0-5][0-5]$/

      #TODO: ipv6 support
      #IPV6 = /(?:[0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}/
      URLREG = /^#{PROTOCOLS}((localhost)|#{DOMAIN}|#{IPV4})#{PORT}(\/.*)?$/ix
      FILEREG = /#{FILEPREFIX}([\w-]*\/?)*/ix # match file based urls
      CONSTANTS_DEFINED = true
    end

    def kipv4?(url)
      !!IPV4_ONLY.match(url_check(url,'host'))
    end

    def kprotocol?(url)
      url_check(url, 'scheme') != false
    end

    def kurl_valid?(url)
      url_check(url)
    end

    def file_prefix?(url)
      url_check(url, 'scheme') == 'file'
    end

    # @param [url] url for validation
    # @param [part] part to check i.E. schema, user, password, host, port. Invalid = all parts
    # @return [checks] return true or false or return the value of a part
    def url_check(url, part=nil)
      part = nil unless %(scheme user password host port).include?(part) if part
      # only available parts of an URL can be checked

      uri = URI.parse(url)

      checks = {}
      checks[:scheme] = %w(http https ftp file).include?(uri.scheme.downcase) ? uri.scheme.downcase : false if uri.scheme
      checks[:user] = uri.user if uri.user
      checks[:password] = uri.password if uri.password
      case checks[:scheme]
        when 'http', 'https', 'ftp'
          checks[:host] = if !!IPV4_ONLY.match(uri.host)
                            uri.host
                          else
                            (DOMAIN.match(uri.host) || uri.host=='localhost') ? uri.host : false
                          end
        else
          checks[:scheme] = !!FILEREG.match(uri.path) ? 'file' : false
          checks[:path] = uri.path
      end
      checks[:port] = ((uri.port.is_a?(Fixnum) && uri.port < 99999 && uri.port > 0) ? uri.port : false) if uri.port

      # return the asked part or validate the url
      part.nil? ? !checks.values.include?(false) : checks[part.to_sym]
    end
  end
end
