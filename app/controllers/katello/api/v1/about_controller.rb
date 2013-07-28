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
  class Api::V1::AboutController < Api::V1::ApiController

    before_filter :authorize # ok - anyone authenticated can ask for status

    def rules
      {
        :index => lambda { true }
      }
    end

    api :GET, "/about", "Shows status of system and it's subcomponents"
    description "This service is only available for authenticated users"
    def index
      @packages = Ping.packages
      @system_info = {  _("Application") => Katello.config.app_name,
                        _("Version")     => Katello.config.katello_version,
                        _("Packages")    => Ping.packages,
                     }
      if current_user && current_user.allowed_to?(:read, :organizations)
        @system_info.merge!(_("Environment") => Rails.env,
                            _("Directory")   => Rails.root,
                            _("Authentication") => Katello.config.warden,
                            "Ruby" => RUBY_VERSION
                           )
      end

      respond_for_show :resource => @system_info
    end

  end
end
