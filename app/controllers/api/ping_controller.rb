#
# Copyright 2011 Red Hat, Inc.
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

  api :GET, "/ping", "Shows status of system and it's subcomponents"
  def index
    render :json => Ping.ping().to_json and return
  end

  api :GET, "/status", "Shows version information"
  def status
    render :json => {:version => "katello/#{AppConfig.katello_version}", :result => true}
  end

  api :GET, "/version", "Shows name and version information"
  def version
    render :json => {:name => AppConfig.app_name, :version => AppConfig.katello_version}
  end
end
