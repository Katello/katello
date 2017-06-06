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

class Api::RolesController < Api::ApiController

  before_filter :find_role, :only => [:show, :update, :destroy]
  before_filter :find_optional_organization, :only => [:available_verbs]
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

  def param_rules
     {
       :create => {:role => [:name, :description]},
       :update => {:role => [:name, :description]},
     }
  end

  def_param_group :role do
    param :role, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true
      param :description, String, :allow_nil => true
    end
  end

  api :GET, "/roles", "List roles"
  api :GET, "/users/:user_id/roles", "List roles assigned to a user"
  param :name, :undef
  def index
    render :json => (Role.readable.non_self.where query_params).to_json
  end

  api :GET, "/roles/:id", "Show a role"
  api :GET, "/users/:user_id/roles/:id", "Show a role"
  def show
    render :json => @role
  end

  api :POST, "/roles", "Create a role"
  api :POST, "/users/:user_id/roles", "Create a role"
  param_group :role
  def create
    render :json => Role.create!(params[:role]).to_json
  end

  api :PUT, "/roles/:id", "Update a role"
  api :PUT, "/users/:user_id/roles/:id", "Update a role"
  param_group :role
  def update
    @role.update_attributes!(params[:role])
    @role.save!
    render :json => @role
  end

  api :DELETE, "/roles/:id", "Destroy a role"
  api :DELETE, "/users/:user_id/roles/:id", "Destroy a role"
  def destroy
    @role.destroy
    render :text => _("Deleted role '%s'") % params[:id], :status => 200
  end

  api :GET, "/roles/available_verbs", "List all available verbs that can be set to roles"
  param :organization_id, :identifier, :desc => "With this option specified the listed tags are scoped to the organization."
  def available_verbs
    details= {}

    org_id = @organization ? @organization.id : nil

    ResourceType::TYPES.each do |type, value|
      details[type] = {}
      details[type][:verbs] = Verb.verbs_for(type, false).collect {|name, display_name| VirtualTag.new(name, display_name)}
      details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
      details[type][:tags] = Tag.tags_for(type, org_id).collect { |t| VirtualTag.new(t.name, t.display_name) }
      details[type][:no_tag_verbs] = Verb.no_tag_verbs(type)
      details[type][:global] = value["global"]
      details[type][:name] = value["name"]
    end

    render :json => details
  end

  private

  def find_role
    @role = Role.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find user role '%s'") % params[:id] if @role.nil?
    @role
  end

end
