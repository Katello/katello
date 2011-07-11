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

class FailedAuthenticationController < ActionController::Base
  # warning: this class is NOT based on ApplicationController

  # This method is called when warden stack cannot authenticate UI request
  def unauthenticated_ui
    Rails.logger.warn "Request is unauthenticated_ui for #{request.remote_ip}"

    if request.env['HTTP_X_FORWARDED_USER'].blank?
      redirect_to invalid_user_session_url
    else
      # Generate a flash... In this case, we are not using the ApplicationController::errors.
      # The reason being, this controller purposely does not inherit from ApplicationController;
      # otherwise, these actions would report an error that user must be logged in to perform them. 
      flash[:error] = {"notices" => [_("You do not have valid credentials to access this system. Please contact your administrator.")]}.to_json
      redirect_to show_user_session_url
    end
    
    return false
  end

  # This method is called when warden stack cannot authenticate API request
  def unauthenticated_api
    Rails.logger.warn "Request is unauthenticated_api for #{request.remote_ip}"
    head :status => 401 and return false
  end

end
