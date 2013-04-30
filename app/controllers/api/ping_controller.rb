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

class Api::PingController < Api::ApiController

  skip_before_filter :authorize # ok - anyone authenticated can ask for status
  skip_before_filter :require_user, :only => [:system_status]

  api :GET, "/ping", "Shows status of system and it's subcomponents"
  description "This service is only available for authenticated users"
  def index
    render :json => Ping.ping().to_json and return
  end

  api :GET, "/system_status", "Shows version information"
  description "This service is also available for unauthenticated users"
  def system_status
    render :json => {:release => Katello.config.app_name,
        :version => Katello.config.katello_version,
        :standalone => true,
        :timeUTC => Time.now().getutc(),
        :result => true}
  end

  api :GET, "/version", "Shows name and version information"
  description "This service is only available for authenticated users"
  def version
    render :json => {:name => Katello.config.app_name, :version => Katello.config.katello_version}
  end
end
