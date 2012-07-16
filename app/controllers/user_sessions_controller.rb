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

class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy, :set_org]
  skip_before_filter :require_org
  protect_from_forgery

  skip_before_filter :authorize # ok - need to skip all methods

  def section_id
    "loginpage"
  end  
  
  def new
    if !request.env['HTTP_X_FORWARDED_USER'].blank?
      # if we received the X-Forwarded-User, the user must have logged in via SSO; therefore,
      # attempt to authenticate and log the user in now versus requiring them to enter 
      # credentials 
      login_user
    else
      @disable_password_recovery = AppConfig.warden == 'ldap'
      render "common/user_session", :layout => "converge-ui/login_layout"
    end
  end

  def create
    login_user
  end
  
  def destroy
    logout
    self.current_organization = nil
    notice _("Logout Successful"), {:persist => false}
    redirect_to root_url
  end

  def allowed_orgs
    render :partial=>"/layouts/allowed_orgs", :locals =>{:user=>current_user}
  end
  
  def set_org
    orgs = current_user.allowed_organizations
    org = Organization.find(params[:org_id])
    if org.nil? or !orgs.include?(org)
      notice "Invalid organization", {:level => :error}
      render :nothing => true
    else
      self.current_organization = org
      redirect_to dashboard_index_url
    end
  end
  
  private

  def login_user
    authenticate! :scope => :user
    if logged_in?

      #save the hash anchor if it exsts
      if params[:hash_anchor] and  session[:original_uri] and !session[:original_uri].index("#")
        session[:original_uri] +=  params[:hash_anchor]
      end

      # set the current user in the thread-local variable (before notification)
      User.current = current_user
      # set ldap roles
      current_user.set_ldap_roles if AppConfig.ldap_roles
      # notice the user
      notice _("Login Successful")
      if current_organization.nil?
        render :partial => "/user_sessions/interstitial.js.haml"
      else
        redirect_to dashboard_index_url
      end
    end
  end

  # return simple 401 page (for API authentication errors)
  def return_401
    head :status => 401 and return false
  end
end
