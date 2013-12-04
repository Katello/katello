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
  class UserSessionsController < Katello::ApplicationController
    before_filter :require_user, :only => [:set_org]
    skip_before_filter :require_org
    protect_from_forgery

    skip_before_filter :authorize # ok - need to skip all methods
    skip_before_filter :check_deleted_org

    def set_org
      orgs = current_user.allowed_organizations
      org = Organization.find_by_id(params[:org_id])
      if org.nil? || !orgs.include?(org)
        notify.error _("Invalid organization")
        render :nothing => true
        return
      else
        self.current_organization = org
      end
      if self.current_organization == org
        respond_to do |format|
          format.html { redirect_to dashboard_index_path }
          format.js { render :js => "CUI.Login.Actions.redirecter('#{dashboard_index_url}')" }
        end
      end
    end

  end
end
