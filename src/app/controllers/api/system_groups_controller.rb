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
                                       :add_systems, :remove_systems, :systems, :history, :job]
  before_filter :find_organization, :only => [:index, :create]
  before_filter :authorize

  def rules
    any_readable = lambda{@organization && SystemGroup.any_readable?(@organization)}
    read_perm = lambda{@group.readable?}
    edit_perm = lambda{@group.editable?}
    create_perm = lambda{SystemGroup.creatable?(@organization)}
    destroy_perm = lambda{@group.deletable?}
    locking_perm = lambda{@group.locking?}
    { :index        => any_readable,
      :show         => read_perm,
      :systems      => read_perm,
      :create       => create_perm,
      :update       => edit_perm,
      :destroy      => destroy_perm,
      :add_systems  => edit_perm,
      :remove_systems => edit_perm,
      :lock        => locking_perm,
      :unlock      => locking_perm,
      :history     => read_perm
    }
  end

  def param_rules
    {
      :create => {:system_group=>[:name, :description, :system_ids, :max_systems]},
      :update =>  {:system_group=>[:name, :description, :system_ids, :max_systems]},
      :add_systems => {:system_group=>[:system_ids]},
      :remove_systems => {:system_group=>[:system_ids]}
    }
  end


  respond_to :json

  api :GET, "/organizations/:organization_id/system_groups", "List system groups"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :name, String, :desc => "System group name to filter by"
  def index
    query_params.delete(:organization_id)
    render :json => SystemGroup.readable(@organization).where(query_params)
  end

  api :GET, "/organizations/:organization_id/system_groups/:id", "Show a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  def show
    render :json => @group
  end

  api :PUT, "/organizations/:organization_id/system_groups/:id", "Update a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true do
    param :name, String, :desc => "System group name"
    param :description, String
    param :max_systems, Integer, :desc => "Maximum number of systems in the group"
  end
  def update
    grp_param = params[:system_group]
    if grp_param[:system_ids]
      grp_param[:system_ids] = system_uuids_to_ids(grp_param[:system_ids])
    end
    @group.attributes = grp_param.slice(:name, :description, :system_ids, :max_systems)
    @group.save!
    render :json => @group
  end

  api :GET, "/organizations/:organization_id/system_groups/:id/systems", "List systems in the group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  def systems
    render :json => @group.systems.collect{|sys| {:id=>sys.uuid, :name=>sys.name}}
  end 

  api :POST, "/organizations/:organization_id/system_groups/:id/add_systems", "Add systems to the group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true do
    param :system_ids, Array, :desc => "Array of system ids"
  end
  def add_systems
    ids = system_uuids_to_ids(params[:system_group][:system_ids])
    @systems = System.readable(@group.organization).where(:id=>ids)
    @group.system_ids = (@group.system_ids + @systems.collect{|s| s.id}).uniq
    @group.save!
    systems
  end

  api :POST, "/organizations/:organization_id/system_groups/:id/remove_systems", "Remove systems from the group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  param :system_group, Hash, :required => true do
    param :system_ids, Array, :desc => "Array of system ids"
  end
  def remove_systems
    ids = system_uuids_to_ids(params[:system_group][:system_ids])
    system_ids = System.readable(@group.organization).where(:id=>ids).collect{|s| s.id}
    @group.system_ids = (@group.system_ids - system_ids).uniq
    @group.save!
    systems
  end

  api :GET ,"/organizations/:organization_id/system_groups/:id/history", "History of jobs performed on a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  param :job_id, :identifier, :desc => "Id of a job for filtering"
  def history
    if params[:job_id]
      jobs = @group.jobs.where(:id=>params[:job_id])
    else
      jobs = @group.jobs
    end
    render :json=> jobs

  end

  api :POST ,"/organizations/:organization_id/system_groups/:id/lock", "Lock the system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  def lock
    @group.locked = true
    @group.save!
    render :json => @group
  end

  api :POST ,"/organizations/:organization_id/system_groups/:id/unlock", "Unlock the system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
  def unlock
    @group.locked = false
    @group.save!
    render :json => @group
  end

  api :POST, "/organizations/:organization_id/system_groups", "Create a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :system_group , Hash , :required => true do
      param :name, String, :desc => "System group name", :required => true
      param :description, String
      param :max_systems, Integer, :desc => "Maximum number of systems in the group", :required => true
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


  api :DELETE, "/organizations/:organization_id/system_groups/:id", "Destroy a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, Integer, :desc => "Id of the system group", :required => true
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
