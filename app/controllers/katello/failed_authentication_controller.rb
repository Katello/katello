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
  class FailedAuthenticationController < ActionController::Base
    # warning: this class is NOT based on ApplicationController

    # This method is called when warden stack cannot authenticate UI request
    def unauthenticated_ui
      Rails.logger.warn "Request is unauthenticated_ui for #{request.remote_ip}"

      # The logic below will generate a flash vs using ApplicationController::errors.
      # The reason being, this controller purposely does not inherit from ApplicationController;
      # otherwise, these actions would report an error that user must be logged in to perform them.
      message = _("You have entered an incorrect username/password combination, or your account may currently be disabled. Please try again or contact your administrator.")

      respond_to do |format|
        format.json { render :json => { :notices => [ message ] }, :status => 401 }
        format.all do
          if request.env['HTTP_X_FORWARDED_USER'].blank?
            path = new_user_session_url(:sso_tried => true)
          else
            message = _("You do not have valid credentials to access this system. Please contact your administrator.")
            path = show_user_session_url
          end

          flash[:error] = {'notices' => [ message ] }.to_json
          redirect_to path
        end
      end

      return false
    end

    # This method is called when warden stack cannot authenticate API request
    def unauthenticated_api
      Rails.logger.warn "Request is unauthenticated_api for #{request.remote_ip}"
      m = "Invalid credentials"
      respond_to do |format|
        format.json { render :json => {:displayMessage => m, :errors => [m] }, :status => 401 }
        format.all  { render :text => m, :status => 401 }
      end
    end

    # In case Warden would fail this returns some reasonable output too
    # warden stores it's options, for API request a scope is :api,
    # when the scope is nil it's using a default one (currently :user that is used fo UI)
    def unauthenticated
      if request.env['warden.options'][:scope] == :api
        unauthenticated_api
      else
        unauthenticated_ui
      end
    end
  end
end
