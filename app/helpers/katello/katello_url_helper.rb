#
# Copyright 2013 Red Hat, Inc.
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
  module KatelloUrlHelper

    unless defined? CONSTANTS_DEFINED
      PORT = /(([:]\d{1,5})?)/
      PROTOCOLS = /(https?|ftp):\/\//ix
      FILEPREFIX = /(^file:\/\/)|^\//ix # is this a file based url
      # validation of hostname according to RFC952 and RFC1123
      DOMAIN = /(?:(?:(?:(?:[a-z0-9][-a-z0-9]{0,61})?[a-z0-9])[.])*(?:[a-z][-a-z0-9]{0,61}[a-z0-9]|[a-z])[.]?)/
      IPV4 = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
      #TODO: ipv6 support
      #IPV6 = /(?:[0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}/
      URLREG = /^#{PROTOCOLS}((localhost)|#{DOMAIN}|#{IPV4})#{PORT}(\/.*)?$/ix
      FILEREG = /#{FILEPREFIX}([\w-]*\/?)*/ix # match file based urls
      CONSTANTS_DEFINED = true
    end

    def kipv4?(url)
      !!IPV4.match(url)
    end

    def kprotocol?(url)
      regex = /^#{PROTOCOLS}/
      !!regex.match(url)
    end

    def kurl_valid?(url)
      !!(file_prefix?(url) ? FILEREG.match(url) : URLREG.match(url))
    end

    def file_prefix?(url)
      !!FILEPREFIX.match(url)
    end

  end
end
