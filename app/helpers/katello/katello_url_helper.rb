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
