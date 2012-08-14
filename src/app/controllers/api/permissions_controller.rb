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

  before_filter :find_role, :only => [:index, :create]
  before_filter :find_optional_organization, :only => [:create]
  before_filter :find_permission, :only => [:destroy, :show]
  before_filter :authorize
  respond_to :json

  def rules
    index_test = lambda{Role.any_readable?}
    create_test = lambda{Role.creatable?}
    read_test = lambda{Role.any_readable?}
    delete_test = lambda{Role.deletable?}

     {
       :index => index_test,
       :show => read_test,
       :create => create_test,
       :destroy => delete_test,
       :available_verbs => read_test
     }
  end
  def param_rules
     {
       :create => [:name, :description, :role_id, :organization_id, :verbs, :tags, :type,:type ]
     }
  end


  api :GET, "/roles/:role_id/permissions", "List permissions for a role"
  param :name, String, :desc => "filter by name"
  param :description, String, :desc => "filter by description"
  param :all_verbs, :bool, :desc => "filter by all_verbs flag"
  param :all_tags, :bool, :desc => "filter by all_flags flag"
  def index
    render :json => @role.permissions.where(query_params).to_json()
  end

  api :GET, "/roles/:role_id/permissions/:id", "Show a permission"
  def show
    render :json => @permission.to_json()
  end


  api :POST, "/roles/:role_id/permissions", "Create a roles permission"
  param :description, String, :allow_nil => true
  param :name, String, :required => true
  param :organization_id, :identifier
  param :tags, Array, :desc => "array of tag ids"
  param :type, String, :desc => "name of a resource or 'all'", :required => true
  param :verbs, Array, :desc => "array of permission verbs"
  def create
    new_params = {
      :name => params[:name],
      :description => params[:description],
      :role => @role,
      :organization => @organization
    }
    new_params[:verb_values] = params[:verbs] || []
    new_params[:tag_values] = params[:tags] || []

    if params[:type] == "all"
      new_params[:all_tags] = true
      new_params[:all_verbs] = true
    end

    new_params[:resource_type] = ResourceType.find_or_create_by_name(params[:type])

    @permission = Permission.create! new_params
    render :json => @permission.to_json()
  end


  api :DELETE, "/roles/:role_id/permissions/:id", "Destroy a roles permission"
  def destroy
    @permission.destroy
    render :text => _("Deleted permission '#{params[:id]}'"), :status => 200
  end

  private

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
