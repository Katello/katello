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
  class Api::V2::PingController < Api::V2::ApiController

    resource_description do
      api_version "v2"
    end

    skip_before_filter :authorize
    skip_before_filter :require_user, :only => [:server_status]

    api :GET, "/ping", "Shows status of system and it's subcomponents"
    description "This service is only available for authenticated users"
    def index
      respond_for_show :resource => Ping.ping
    end

    api :GET, "/status", "Shows version information"
    description "This service is available for unauthenticated users"
    def server_status
      # rubocop:disable SymbolName
      status = { :release    => Katello.config.app_name,
                 :version    => Katello.config.katello_version,
                 :timeUTC    => Time.now.getutc }
      respond_for_show :resource => status, :template => "server_status"
    end

  end
end
