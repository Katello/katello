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

class PasswordResetsController < ApplicationController
  before_filter :find_user_by_user_and_email, :only => [:create]
  before_filter :find_users_by_email, :only => [:email_logins]
  before_filter :find_user_by_token, :only => [:edit, :update]

  before_filter :require_no_user, :only => [:new, :create, :edit, :update]
  before_filter :require_user, :only => [:destroy, :set_org]
  skip_before_filter :require_org
  skip_before_filter :authorize

  def section_id
    "passwordreset"
  end

  def new
  end

  def create
    @user.send_password_reset if @user
    flash[:success] = {"notices" => [_("Email sent to '%{e}' with password reset instructions." % {:e => @user.email})]}.to_json
    render :text => ""
  end

  def edit
  end

  def update
    # TODO : make the timeframe configurable
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:error] = {"notices" => [_("Password reset token has expired for user '%{s}'." % {:s => @user.username})]}.to_json
      redirect_to new_password_reset_path
    elsif @user.update_attributes(params[:user])
      flash[:success] = {"notices" => [_("Password has been reset for user '%{s}'." % {:s => @user.username})]}.to_json
      redirect_to root_url
    else
      render :edit
    end
  end

  def email_logins
    # request to have the usernames associated with the email address provided, sent (in email) to that address
    UserMailer.send_logins(@users)
    flash[:success] = {"notices" => [_("Email sent to '%{e}' with valid login user names." % {:e => params[:email]})]}.to_json
    render :text => ""
  end

  protected

  def find_user_by_user_and_email
    begin
      @user = User.find_by_username_and_email(params[:username], params[:email])
    rescue Exception => error
      flash[:error] = {"notices" => [error.to_s]}.to_json
      redirect_to root_url
      execute_after_filters
    end
  end

  def find_users_by_email
    begin
      @users = User.where(:email => params[:email])
    rescue Exception => error
      flash[:error] = {"notices" => [error.to_s]}.to_json
      redirect_to root_url
      execute_after_filters
    end
  end

  def find_user_by_token
    begin
      @user = User.find_by_password_reset_token!(params[:id])
    rescue Exception => error
      flash[:error] = {"notices" => [_("Request received has either an invalid or expired token.  Token: '%{t}'" % {:t => params[:id]})]}.to_json
      redirect_to root_url
      execute_after_filters
    end
  end
end
