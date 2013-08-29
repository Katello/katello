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

class PasswordResetsController < ApplicationController
  include PasswordResetsHelper

  before_filter :find_user_by_user_and_email, :only => [:create]
  before_filter :find_users_by_email, :only => [:email_logins]
  before_filter :find_user_by_token, :only => [:edit, :update]

  skip_before_filter :require_user, :require_org, :authorize

  def section_id
    "loginpage"
  end

  def param_rules
    {
      :create =>[:username, :email],
      :update => {:user  => [:password]}
    }
  end

  def create
    @user.send_password_reset if @user

    # note: we provide a success notice regardless of whether or not there are any users associated with the email
    # address provided... this is done on purpose for security
    flash[:success] = _("Email sent to '%s' with password reset instructions.") % params[:email]
    render :partial=>"password_refresh"
  end

  def edit
    if @user.password_reset_sent_at < password_reset_expiration.minutes.ago
      notify.warning _("Password reset token has expired for user '%s'.") % @user.username
      redirect_to login_path(:card => 'password_reset')
    else
      redirect_to new_user_session_path
    end
  end

  def update
    if @user.password_reset_sent_at < password_reset_expiration.minutes.ago
      notify.warning _("Password reset token has expired for user '%s'.") % @user.username
      if redirect_to new_password_reset_path
        return
      end
    end

    # update the password and reset the 'password reset token' so that it cannot be reused
    params[:user][:password_reset_token]   = nil
    params[:user][:password_reset_sent_at] = nil

    if @user.update_attributes(params[:user])
      notify.success _("Password has been reset for user '%s'.") % @user.username, :persist => false
      render :nothing => true
    else
      notify.invalid_record @user
      render :nothing => true
    end
  end

  def email_logins
    # request to have the usernames associated with the email address provided, sent (in email) to that address
    UserMailer.send_logins(@users) if !@users.empty?

    # note: we provide a success notice regardless of whether or not there are any users associated with the email
    # address provided... this is done on purpose for security
    flash[:success] = _("Email sent to '%s' with valid login user names.") % params[:email]
    render :partial => "username_refresh"
  end

  protected

  def find_user_by_user_and_email
    @user = User.find_by_username_and_email(params[:username], params[:email])
    User.current = @user
  end

  def find_users_by_email
    @users = User.find_all_by_email(params[:email])
    User.current = @users.first
  end

  def find_user_by_token
    @user = User.find_by_password_reset_token!(params[:id])
    User.current = @user
  rescue ActiveRecord::RecordNotFound
    notify.error _("Request received has either an invalid or expired token. Token: '%s'") % params[:id]
    redirect_to root_url
    execute_after_filters
  end

  private

  def default_notify_options
    super.merge :organization => nil
  end
end
