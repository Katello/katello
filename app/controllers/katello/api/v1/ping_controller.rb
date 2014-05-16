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
  class Api::V1::PingController < Api::V1::ApiController

    skip_before_filter :authorize # ok - anyone authenticated can ask for status
    skip_before_filter :require_user, :only => [:server_status]

    api :GET, "/ping", N_("Shows status of system and it's subcomponents")
    description N_("This service is only available for authenticated users")
    def index
      resource = Hash[Ping.ping.collect { |k, v| [{:status => :result, :services => :status}[k], v] }]
      resource[:status].each_key do |key|
        resource[:status][key][:result] = resource[:status][key][:status]
      end
      respond_for_show :resource => resource
    end

    api :GET, "/status", N_("Shows version information")
    description N_("This service is also available for unauthenticated users")
    def server_status
      # rubocop:disable SymbolName
      status = { :release    => Katello.config.app_name,
                 :version    => Katello.config.katello_version,
                 :standalone => true,
                 :timeUTC    => Time.now.getutc,
                 :result     => true }
      respond_for_show :resource => status
    end

    api :GET, "/version", N_("Shows name and version information")
    description N_("This service is only available for authenticated users")
    def version
      respond_for_show :resource => { :name => Katello.config.app_mode, :version => Katello.config.katello_version }
    end
  end
end
