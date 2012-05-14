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

class Api::RolesController < Api::ApiController

  before_filter :find_role, :only => [:show, :update, :destroy]
  before_filter :find_organization, :only => [:available_verbs]
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

  def index
    render :json => (Role.readable.non_self.where query_params).to_json
  end

  def show
    render :json => @role
  end

  def create
    render :json => Role.create!(params[:role]).to_json
  end

  def update
    @role.update_attributes!(params[:role])
    @role.save!
    render :json => @role
  end

  def destroy
    @role.destroy
    render :text => _("Deleted role '#{params[:id]}'"), :status => 200
  end

  def available_verbs
    details= {}
 
    orgId = @organization ? @organization.id : nil

    ResourceType::TYPES.each do |type, value|
      details[type] = {}
      details[type][:verbs] = Verb.verbs_for(type, false).collect {|name, display_name| VirtualTag.new(name, display_name)}
      details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
      details[type][:tags] = Tag.tags_for(type, orgId).collect { |t| VirtualTag.new(t.name, t.display_name) }
      details[type][:global] = value["global"]
      details[type][:name] = value["name"]
    end
    
    render :json => details
  end


  def find_role
    @role = Role.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find user role '#{params[:id]}'") if @role.nil?
    @role 
  end

end
