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

class Api::UsersController < Api::ApiController

  before_filter :find_user, :only => [:show, :update, :destroy]
  before_filter :authorize
  respond_to :json

  def rules
    index_test = lambda{User.any_readable?}
    create_test = lambda{User.creatable?}

    read_test = lambda{@user.readable?}
    edit_test = lambda{@user.editable?}
    delete_test = lambda{@user.deletable?}
    user_helptip = lambda{true} #everyone can enable disable a helptip

     {
       :index => index_test,
       :show => read_test,
       :create => create_test,
       :update => edit_test,
       :destroy => delete_test,
     }
  end

  def index
    render :json => (User.readable.where query_params).to_json
  end

  def show
    render :json => @user
  end

  def create
    # warning - request already contains "username" and "password" (logged user)
    render :json => User.create!(
      :username => params[:username],
      :password => params[:password],
      :disabled=> params[:disabled]
    ).to_json
  end

  def update
    render :json => @user.update_attributes!(params[:user]).to_json
  end

  def destroy
    @user.destroy
    render :text => _("Deleted user '#{params[:id]}'"), :status => 200
  end

  def find_user
    @user = User.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find user '#{params[:id]}'") if @user.nil?
    @user
  end
end
