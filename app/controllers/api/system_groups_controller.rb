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


class Api::SystemGroupsController < Api::ApiController

  before_filter :find_group, :only => [:copy, :show, :update, :destroy, :destroy_systems,
                                       :add_systems, :remove_systems, :systems, :history,
                                       :history_show, :update_systems]
  before_filter :find_organization, :only => [:index, :create, :copy]
  before_filter :authorize

  def rules
    any_readable = lambda{@organization && SystemGroup.any_readable?(@organization)}
    read_perm = lambda{@group.readable?}
    edit_perm = lambda{@group.editable?}
    create_perm = lambda{SystemGroup.creatable?(@organization)}
    destroy_perm = lambda{@group.deletable?}
    destroy_systems_perm = lambda{@group.systems_deletable?}
    { :index           => any_readable,
      :show            => read_perm,
      :systems         => read_perm,
      :create          => create_perm,
      :copy            => create_perm,
      :update          => edit_perm,
      :destroy         => destroy_perm,
      :destroy_systems => destroy_systems_perm,
      :add_systems     => edit_perm,
      :remove_systems  => edit_perm,
      :history         => read_perm,
      :history_show    => read_perm,
      :update_systems  => edit_perm
    }
  end

  def param_rules
    {
      :create => {:system_group=>[:name, :description, :system_ids, :max_systems]},
      :copy => {:system_group=>[:new_name, :description, :max_systems]},
      :update =>  {:system_group=>[:name, :description, :system_ids, :max_systems]},
      :add_systems => {:system_group=>[:system_ids]},
      :remove_systems => {:system_group=>[:system_ids]},
      :update_systems => {:system_group => [:environment_id, :content_view_id]}
    }
  end

  respond_to :json

  def_param_group :system_group do
    param :system_group, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true, :desc => "System group name"
      param :description, String
      param :max_systems, Integer, :desc => "Maximum number of systems in the group"
    end
  end

  api :GET, "/organizations/:organization_id/system_groups", "List system groups"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :name, String, :desc => "System group name to filter by"
  def index
    query_params.delete(:organization_id)
    render :json => SystemGroup.readable(@organization).where(query_params)
  end

  api :GET, "/organizations/:organization_id/system_groups/:id", "Show a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def show
    render :json => @group.to_json(:methods => :total_systems)
  end

  api :PUT, "/organizations/:organization_id/system_groups/:id", "Update a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param_group :system_group
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
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def systems
    render :json => @group.systems.collect{|sys| {:id=>sys.uuid, :name=>sys.name}}
  end

  api :POST, "/organizations/:organization_id/system_groups/:id/add_systems", "Add systems to the group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
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
  param :id, :identifier, :desc => "Id of the system group", :required => true
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
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def history
    jobs = @group.refreshed_jobs
    render :json => jobs
  end

  api :GET ,"/organizations/:organization_id/system_groups/:id/history", "History of a job performed on a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :job_id, :identifier, :desc => "Id of a job for filtering"
  def history_show
    job = @group.refreshed_jobs.where(:id => params[:job_id]).first
    render :json => job
  end

  api :POST, "/organizations/:organization_id/system_groups", "Create a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param_group :system_group
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

  def copy
    if @organization.id != @group.organization.id
      raise HttpErrors::BadRequest,
        _("Can't copy System Groups to a different org: '%{org1}' != '%{org2}'") % {:org1 => @organization.id, :org2 => @group.organization.id}
    end
    grp_param = params[:system_group]
    new_group = SystemGroup.new
    new_group.name = grp_param[:new_name]
    new_group.organization = @group.organization

    # Check API params and if not set use the existing group
    if grp_param[:description]
      new_group.description = grp_param[:description]
    else
      new_group.description = @group.description
    end
    if grp_param[:max_systems]
      new_group.max_systems = grp_param[:max_systems]
    else
      new_group.max_systems = @group.max_systems
    end
    new_group.save!

    new_group.systems = @group.systems
    new_group.save!
    render :json => new_group
  end

  api :DELETE, "/organizations/:organization_id/system_groups/:id", "Destroy a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def destroy
    @group.destroy
    render :text => _("Deleted system group '%s'") % params[:id], :status => 200
  end

  api :DELETE, "/organizations/:organization_id/system_groups/:id/destroy_systems",
    "Destroy a system group and its systems"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def destroy_systems
    # this will destroy both the systems contained within the group as well as the group itself
    system_names = []
    @group.systems.each do |system|
      system_names.push(system.name)
      system.destroy
    end
    @group.destroy

    result = _("Deleted system group '%{s}' and it's %{n} systems.") % {:s => @group.name, :n =>system_names.length.to_s}
    render :text => result, :status => 200
  end

  api :PUT, "/organizations/:organization_id/system_groups/:id/update_systems",
    "Update systems within a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_group, Hash do
    param :content_view_id, :identifier, "id of the content view to set systems to"
    param :environment_id, :identifier, "id of the enviornment to set systems to"
  end
  def update_systems
    unless params[:system_group].blank?
      ActiveRecord::Base.transaction do
        @group.systems.each do |system|
          system.update_attributes!(params[:system_group])
        end
      end
    end

    render :json => @group
  end

  private

  def find_group
    @group = SystemGroup.where(:id=>params[:id]).first
    raise HttpErrors::NotFound, _("Couldn't find system group '%s'") % params[:id] if @group.nil?
  end

  def system_uuids_to_ids  ids
    system_ids = System.where(:uuid=>ids).collect{|s| s.id}
    raise Errors::NotFound.new(_("Systems [%s] not found.") % ids.join(',')) if system_ids.blank?
    system_ids
  end

end
