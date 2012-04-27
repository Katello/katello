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

  before_filter :find_group, :only => [:show, :update, :destroy, :lock, :unlock,
                                       :add_systems, :remove_systems]
  before_filter :find_organization, :only => [:index, :create]
  before_filter :authorize

  def rules
    read = lambda { true }
    edit = lambda{true}
    create = lambda{true}
    locking = lambda{true}
    destroy = lambda{true}
    { :index        => read,
      :show         => read,
      :systems      => read,
      :create       => create,
      :update       => edit,
      :destroy      => destroy,
      :add_systems  => edit,
      :remove_systems => edit,
      :lock        => locking,
      :unlock      => locking
    }
  end

  def param_rules
    {
      :create => {:system_group=>[:name, :description, :system_ids]},
      :update =>  {:system_group=>[:name, :description, :system_ids]},
      :add_systems => {:system_group=>[:system_ids]},
      :remove_systems => {:system_group=>[:system_ids]}
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
    grp_param = params[:system_group]
    if grp_param[:system_ids]
      grp_param[:system_ids] = system_uuids_to_ids(grp_param[:system_ids])
    end
    @group.attributes = grp_param.slice(:name, :description, :system_ids)
    @group.save!
    render :json => @group
  end

  def systems
    render :json => @group.systems.collect{|sys| {:id=>sys.uuid, :name=>sys.name}}
  end

  def add_systems
    ids = system_uuids_to_ids(params[:system_group][:system_ids])
    @group.system_ids = (@group.system_ids + ids).uniq
    @group.save!
    systems
  end

  def remove_systems
    ids = system_uuids_to_ids(params[:system_group][:system_ids])
    @group.system_ids = (@group.system_ids - ids)
    @group.save!
    systems
  end

  def  lock
    @group.locked = true
    @group.save!
    render :json => @group
  end

  def  unlock
    @group.locked = false
    @group.save!
    render :json => @group
  end

  def create
    grp_param = params[:system_group]
    if grp_param[:system_ids]
      grp_param[:system_ids] = system_ids_to_uuids(grp_param[:system_ids])
    end
    @group = SystemGroup.new(grp_param)
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

  def system_uuids_to_ids  ids
    System.where(:uuid=>ids).collect{|s| s.id}
  end

end
