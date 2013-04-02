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

class Api::V1::PingController < Api::V1::ApiController

  skip_before_filter :authorize # ok - anyone authenticated can ask for status
  skip_before_filter :require_user, :only => [:system_status]

  api :GET, "/ping", "Shows status of system and it's subcomponents"
  description "This service is only available for authenticated users"
  def index
    respond_for_show :resource => Ping.ping()
  end

  api :GET, "/system_status", "Shows version information"
  description "This service is also available for unauthenticated users"
  def server_status

    status = {:release => Katello.config.app_name,
        :version => Katello.config.katello_version,
        :standalone => true,
        :timeUTC => Time.now().getutc(),
        :result => true}
    respond_for_show :resource => status
  end

  api :GET, "/version", "Shows name and version information"
  description "This service is only available for authenticated users"
  def version
    respond_for_show :resource => {:name => Katello.config.app_name, :version => Katello.config.katello_version}
  end
end
