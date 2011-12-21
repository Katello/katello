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

class Api::PermissionsController < Api::ApiController

  before_filter :find_role, :only => [:index]
  before_filter :find_organization, :only => []
  before_filter :find_permission, :only => [:destroy]
  before_filter :authorize
  respond_to :json

  def rules
    index_test = lambda{Role.any_readable?}
    create_test = lambda{Role.creatable?}
    read_test = lambda{Role.any_readable?}
    edit_test = lambda{Role.editable?}
    delete_test = lambda{Role.deletable?}

     {
       :index => index_test,
       :show => read_test,
       :create => create_test,
       :update => edit_test,
       :destroy => delete_test,
       :available_verbs => read_test
     }
  end

  def index
    render :json => @role.permissions.to_json
  end

  def create
    render :json => "creating new permisson"
  end

  def destroy
    @permission.destroy
    render :text => _("Deleted permission '#{params[:id]}'"), :status => 200
  end

  def find_role
    @role = Role.find(params[:role_id])
    raise HttpErrors::NotFound, _("Couldn't find user role '#{params[:role_id]}'") if @role.nil?
    @role
  end

  def find_permission
    @permission = Permission.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find permissions '#{params[:id]}'") if @permission.nil?
    @permission
  end
end
