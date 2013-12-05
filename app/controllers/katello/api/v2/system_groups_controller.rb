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

module Katello
class Api::V2::SystemGroupsController <  Api::V2::ApiController

  before_filter :find_system_group, :only => [:copy, :show, :update, :destroy, :destroy_systems,
                                              :add_systems, :remove_systems, :systems]
  before_filter :find_organization, :only => [:index, :create]
  before_filter :authorize
  before_filter :load_search_service, :only => [:index, :systems]

  def rules
    any_readable         = lambda { @organization && SystemGroup.any_readable?(@organization) }
    read_perm            = lambda { @system_group.readable? }
    edit_perm            = lambda { @system_group.editable? }
    create_perm          = lambda { SystemGroup.creatable?(@organization) }
    destroy_perm         = lambda { @system_group.deletable? }
    { :index           => any_readable,
      :show            => read_perm,
      :systems         => read_perm,
      :create          => create_perm,
      :copy            => create_perm,
      :update          => edit_perm,
      :destroy         => destroy_perm,
      :add_systems     => edit_perm,
      :remove_systems  => edit_perm
    }
  end

  resource_description do
    api_version "v2"
  end

  def_param_group :system_group do
    param :name, String, :required => true, :desc => "System group name"
    param :system_ids, Array, :required => false, :desc => "List of system uuids to be in the group"
    param :description, String
    param :max_systems, Integer, :desc => "Maximum number of systems in the group"
  end

  api :GET, "/system_groups/:id", "Show a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def show
    respond
  end

  api :GET, "/system_groups", "List system groups"
  api :GET, "/organizations/:organization_id/system_groups"
  param_group :search, Api::V2::ApiController
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :name, String, :desc => "system group name to filter by"
  def index
    filters = [:terms => {:id => SystemGroup.readable(@organization).pluck(:id)}]
    filters << {:term => {:name => params[:name].downcase}} if params[:name]

    options = {
        :filters       => filters,
        :load_records? => true
    }
    respond_for_index(:collection => item_search(SystemGroup, params, options))
  end

  api :POST, "/system_groups", "Create a system group"
  api :POST, "/organizations/:organization_id/system_groups", "Create a system group"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param_group :system_group
  def create
    if params[:system_ids]
      params[:system_ids] = system_ids_to_uuids(params[:system_ids])
    end

    @system_group = SystemGroup.new(params.slice(:name, :description, :max_systems, :system_ids))
    @system_group.organization = @organization
    @system_group.save!
    respond
  end

  api :PUT, "/system_groups/:id", "Update a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param_group :system_group
  def update
    params[:system_ids] = system_uuids_to_ids(params[:system_ids]) if params[:system_ids]

    @system_group.attributes = params.slice(:name, :description, :system_ids, :max_systems)
    @system_group.save!
    respond
  end

  # TODO: switch to systems controller index w/ @adprice pull-request
  api :GET, "/system_groups/:id/systems", "List systems in the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  def systems
    options = {
        :filters       => [{:term => {:system_group_ids => @system_group.id }}],
        :load_records? => true
    }
    respond_for_index(:collection => item_search(System, params, options))
  end

  api :PUT, "/system_groups/:id/add_systems", "Add systems to the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_ids, Array, :desc => "Array of system ids"
  def add_systems
    ids = system_uuids_to_ids(params[:system_ids])
    @systems = System.readable(@system_group.organization).where(:id => ids)
    @system_group.system_ids = (@system_group.system_ids + @systems.collect { |s| s.id }).uniq
    @system_group.save!
    System.index.refresh
    respond_for_index(:collection => @system_group.systems, :template => :delta_systems)
  end

  api :PUT, "/system_groups/:id/remove_systems", "Remove systems from the group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :system_ids, Array, :desc => "Array of system ids"
  def remove_systems
    ids = system_uuids_to_ids(params[:system_ids])
    system_ids = System.readable(@system_group.organization).where(:id => ids).collect { |s| s.id }
    @system_group.system_ids = (@system_group.system_ids - system_ids).uniq
    @system_group.save!
    System.index.refresh
    respond_for_index(:collection => @system_group.systems, :template => :delta_systems)
  end

  api :GET, "/system_groups/:id/history", "History of jobs performed on a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  # TODO: v2 update
  def history
    super
  end

  api :GET, "/system_groups/:id/history", "History of a job performed on a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  param :job_id, :identifier, :desc => "Id of a job for filtering"
  # TODO: v2 update
  def history_show
    super
  end

  api :POST, "/system_groups/:id/copy", "Make copy of a system group"
  param :id, :identifier, :desc => "ID of the system group", :required => true
  param :new_name, String, :required => true, :desc => "system group name"
  param :description, String
  param :max_systems, Integer, :desc => "maximum number of systems in the group"
  def copy
    super
  end

  api :DELETE, "/system_groups/:id", "Destroy a system group"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  # TODO: v2 update
  def destroy
    @system_group.destroy
    respond_for_destroy
  end

  api :DELETE, "/system_groups/:id/destroy_systems", "Destroy a system group nad contained systems"
  param :id, :identifier, :desc => "Id of the system group", :required => true
  # TODO: v2 update
  def destroy_systems
    super
  end

  api :POST, "/system_groups/:id/copy", "Make copy of a system group"
  param :id, :identifier, :desc => "ID of the system group", :required => true
  param :name, String, :required => true, :desc => "New system group name"
  def copy
    new_group              = SystemGroup.new
    new_group.name         = params[:system_group][:name]
    new_group.organization = @system_group.organization
    new_group.description = @system_group.description
    new_group.max_systems = @system_group.max_systems
    new_group.systems = @system_group.systems
    new_group.save!
    respond_for_create :resource => new_group
  end

  private

  def find_system_group
    @system_group = SystemGroup.where(:id => params[:id]).first
    fail HttpErrors::NotFound, _("Couldn't find system group '%s'") % params[:id] if @system_group.nil?
  end

  def system_uuids_to_ids(ids)
    system_ids = System.where(:uuid => ids).collect { |s| s.id }
    fail Errors::NotFound.new(_("Systems [%s] not found.") % ids.join(',')) if system_ids.blank?
    system_ids
  end

end
end
