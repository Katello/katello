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

class Api::SystemGroupsController < Api::ApiController

  before_filter :find_group, :only => [:show, :update]
  before_filter :find_organization, :only => [:index, :create]
  before_filter :authorize

  def rules
    read = lambda { true }
    edit = lambda{true}
    create = lambda{true}
    destroy = lambda{true}
    { :index        => read,
      :show         => read,
      :systems      => read,
      :create       => create,
      :update       => edit,
      :destroy      => destroy
    }
  end

  def param_rules
    {
      :create => {:system_group=>[:name, :description, :system_ids]},
      :update =>  {:system_group=>[:name, :description, :system_ids]}
    }
  end


  respond_to :json

  def index
    query_params.delete(:organization_id)
    render :json => SystemGroup.readable(@organization).where(query_params)
  end

  def show
    render :json => @group
  end

  def update
    @group.attributes = params[:group].slice(:name, :description)
    @group.save!
    render :json => @group
  end

  def systems
    render :json => @group.systems.collect{|sys| {:id=>sys.id, :name=>sys.name}}
  end


  def create
    @group = SystemGroup.new(params[:system_group])
    @group.organization = @organization
    @group.save!

    render :json => @group
  end


  def destroy
    @group.destroy
    render :text => _("Deleted system group '#{params[:id]}'"), :status => 200
  end

  private

  def find_group
    @group = SystemGroup.where(:id=>params[:id]).first
    raise HttpErrors::NotFound, _("Couldn't find system group '#{params[:id]}'") if @group.nil?
  end

end
