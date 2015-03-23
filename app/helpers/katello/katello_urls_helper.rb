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

require 'uri'
module Katello
  module KatelloUrlsHelper
    def host(url)
      URI(url).host unless url.nil?
    end

    def subscription_manager_configuration_url(host = nil)
      prefix = if host && host.content_source
                 "http://#{@host.content_source.hostname}"
               else
                 Setting[:foreman_url].sub(/\Ahttps/, 'http')
               end

      "#{prefix}/pub/#{Katello.config.consumer_cert_rpm}"
    end
  end
end
