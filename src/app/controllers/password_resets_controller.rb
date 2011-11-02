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
  before_filter :find_user_by_email, :only => [:create]
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
    flash[:success] = {"notices" => [_("Email sent with password reset instructions.")]}.to_json
    redirect_to root_url
  end

  def edit
  end

  def update
    # TODO : make the timeframe configurable
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:error] = {"notices" => [_("Password reset has expired.")]}.to_json
      redirect_to new_password_reset_path
    elsif @user.update_attributes(params[:user])
      flash[:success] = {"notices" => [_("Password has been reset.")]}.to_json
      redirect_to root_url
    else
      render :edit
    end
  end

  def get_logins
    # request to have the usernames associated with the email address provided, sent (in email) to that address
  end

  protected

  def find_user_by_email
    begin
      @user = User.find_by_username_and_email(params[:username], params[:email])
    rescue Exception => error
      flash[:error] = {"notices" => error.to_s}.to_json
      execute_after_filters
      redirect_to root_url
    end
  end

  def find_user_by_token
    begin
      @user = User.find_by_password_reset_token!(params[:id])
    rescue Exception => error
      flash[:error] = {"notices" => error.to_s}.to_json
      execute_after_filters
      redirect_to root_url
    end
  end
end
