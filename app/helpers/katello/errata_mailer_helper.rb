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
  module ErrataMailerHelper
    def content_host_errata_path(content_host)
      uuid = Katello::System.find(content_host).uuid
      "#{Setting[:foreman_url]}/content_hosts/#{uuid}/errata"
    end

    def erratum_path(erratum)
      "#{Setting[:foreman_url]}/errata/#{erratum.uuid}/info"
    end

    def errata_count(host, errata_type)
      available = host.available_errata.send(errata_type.to_sym).count
      applicable = host.applicable_errata.send(errata_type.to_sym).count - available
      "#{available} (#{applicable})"
    end

    def format_summary(summary)
      summary.gsub(/\n\n/, '<p>').gsub(/\n/, ' ').html_safe
    end

    def host_count(hosts, errata_type)
      hosts.count { |host| host.available_errata.send(errata_type.to_sym).any? }
    end
  end
end
