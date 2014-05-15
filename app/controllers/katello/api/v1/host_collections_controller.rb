#
# Copyright 2014 Red Hat, Inc.
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
class Api::V1::HostCollectionsController < Api::V1::ApiController

  before_filter :find_host_collection, :only => [:copy, :show, :update, :destroy, :destroy_content_hosts,
                                                 :add_content_hosts, :remove_content_hosts, :content_hosts, :history,
                                                 :history_show, :update_content_hosts]
  before_filter :find_organization, :only => [:index, :create, :copy]
  before_filter :authorize

  after_filter :refresh_index, :only => [:create, :update]

  def rules
    any_readable         = lambda { @organization && HostCollection.any_readable?(@organization) }
    read_perm            = lambda { @host_collection.readable? }
    edit_perm            = lambda { @host_collection.editable? }
    create_perm          = lambda { HostCollection.creatable?(@organization) }
    destroy_perm         = lambda { @host_collection.deletable? }
    destroy_content_hosts_perm = lambda { @host_collection.content_hosts_deletable? }
    { :index           => any_readable,
      :show            => read_perm,
      :content_hosts   => read_perm,
      :create          => create_perm,
      :copy            => create_perm,
      :update          => edit_perm,
      :destroy         => destroy_perm,
      :destroy_content_hosts => destroy_content_hosts_perm,
      :add_content_hosts     => edit_perm,
      :remove_content_hosts  => edit_perm,
      :history               => read_perm,
      :history_show          => read_perm,
      :update_content_hosts  => edit_perm
    }
  end

  def param_rules
    {
        :create         => { :host_collection => [:name, :description, :system_ids, :max_content_hosts] },
        :copy           => { :host_collection => [:new_name, :description, :max_content_hosts] },
        :update         => { :host_collection => [:name, :description, :system_ids, :max_content_hosts] },
        :add_content_hosts    => { :host_collection => [:system_ids] },
        :remove_content_hosts => { :host_collection => [:system_ids] },
        :update_content_hosts => { :host_collection => [:environment_id, :content_view_id] }
    }
  end

  respond_to :json

  def_param_group :host_collection do
    param :host_collection, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true, :desc => N_("Host collection name")
      param :description, String
      param :max_content_hosts, Integer, :desc => N_("Maximum number of content hosts in the host collection")
    end
  end

  api :GET, "/organizations/:organization_id/host_collections", N_("List host collections")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :name, String, :desc => N_("Host collection name to filter by")
  def index
    query_string = params[:search]

    filters = [:terms => {:id => HostCollection.readable(@organization).pluck(:id)}]
    #downcase filtered analyzed field
    filters << {:term => {:name => params[:name].downcase}} if params[:name]

    options = {
        :filters => filters
    }
    options.merge!(params.slice(:sort_by, :sort_order))

    if params[:paged]
      options[:page_size] = params[:page_size] || current_user.page_size
    end

    items = Glue::ElasticSearch::Items.new(HostCollection)
    host_collections, total_count = items.retrieve(query_string, params[:offset], options)

    if params[:paged]
      host_collections = {
        :host_collections  => host_collections,
        :subtotal          => total_count,
        :total             => items.total_items
      }
    end

    respond :collection => host_collections
  end

  api :GET, "/organizations/:organization_id/host_collections/:id", N_("Show a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  def show
    respond
  end

  api :PUT, "/organizations/:organization_id/host_collections/:id", N_("Update a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param_group :host_collection
  def update
    host_collection_param = params[:host_collection]
    if host_collection_param[:system_ids]
      host_collection_param[:system_ids] = system_uuids_to_ids(host_collection_param[:system_ids])
    end
    @host_collection.attributes = host_collection_param.slice(:name, :description, :system_ids, :max_content_hosts)
    @host_collection.save!
    respond
  end

  api :GET, "/organizations/:organization_id/host_collections/:id/content_hosts", N_("List content hosts in the host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  def content_hosts
    respond_for_index :collection => @host_collection.systems.collect { |sys| { :id => sys.uuid, :name => sys.name } }
  end

  api :POST, "/organizations/:organization_id/host_collections/:id/add_content_hosts", N_("Add content hosts to the host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param :host_collection, Hash, :required => true do
    param :system_ids, Array, :desc => N_("Array of content host ids")
  end

  def add_content_hosts
    ids                         = system_uuids_to_ids(params[:host_collection][:system_ids])
    @systems                    = System.readable(@host_collection.organization).where(:id => ids)
    @host_collection.system_ids = (@host_collection.system_ids + @systems.collect { |s| s.id }).uniq
    @host_collection.save!
    systems
  end

  api :POST, "/organizations/:organization_id/host_collections/:id/remove_content_hosts", N_("Remove content hosts from the host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param :host_collection, Hash, :required => true do
    param :system_ids, Array, :desc => N_("Array of system ids")
  end
  def remove_content_hosts
    ids                         = system_uuids_to_ids(params[:host_collection][:system_ids])
    system_ids                  = System.readable(@host_collection.organization).where(:id => ids).collect { |s| s.id }
    @host_collection.system_ids = (@host_collection.system_ids - system_ids).uniq
    @host_collection.save!
    systems
  end

  api :GET, "/organizations/:organization_id/host_collections/:id/history", N_("History of jobs performed on a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  def history
    jobs = @host_collection.refreshed_jobs
    respond_for_index :collection => jobs
  end

  api :GET, "/organizations/:organization_id/host_collections/:id/history", N_("History of a job performed on a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param :job_id, :identifier, :desc => N_("Id of a job for filtering")
  def history_show
    job = @host_collection.refreshed_jobs.where(:id => params[:job_id]).first
    respond_for_show :resource => job
  end

  api :POST, "/organizations/:organization_id/host_collections", N_("Create a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param_group :host_collection
  def create
    host_collection_param = params[:host_collection]
    if host_collection_param[:system_ids]
      host_collection_param[:system_ids] = system_ids_to_uuids(host_collection_param[:system_ids])
    end
    @host_collection              = HostCollection.new(host_collection_param)
    @host_collection.organization = @organization
    @host_collection.save!
    respond
  end

  api :POST, "/organizations/:organization_id/host_collections/:id/copy", N_("Make copy of a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param :host_collection, Hash, :required => true, :action_aware => true do
    param :new_name, String, :required => true, :desc => N_("Host collection name")
    param :description, String
    param :max_content_hosts, Integer, :desc => N_("Maximum number of content hosts in the host collection")
  end
  def copy
    if @organization.id != @host_collection.organization.id
      fail HttpErrors::BadRequest,
            _("Can't copy host collections to a different org: '%{org1}' != '%{org2}'") % { :org1 => @organization.id, :org2 => @host_collection.organization.id }
    end
    host_collection_param            = params[:host_collection]
    new_host_collection              = HostCollection.new
    new_host_collection.name         = host_collection_param[:new_name]
    new_host_collection.organization = @host_collection.organization

    # Check API params and if not set use the existing host collection
    if host_collection_param[:description]
      new_host_collection.description = host_collection_param[:description]
    else
      new_host_collection.description = @host_collection.description
    end
    if host_collection_param[:max_content_hosts]
      new_host_collection.max_content_hosts = host_collection_param[:max_content_hosts]
    else
      new_host_collection.max_content_hosts = @host_collection.max_content_hosts
    end
    new_host_collection.save!

    new_host_collection.systems = @host_collection.systems
    new_host_collection.save!
    respond_for_create :resource => new_host_collection
  end

  api :DELETE, "/organizations/:organization_id/host_collections/:id", N_("Destroy a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  def destroy
    @host_collection.destroy
    respond :message => _("Deleted host collection '%s'") % params[:id]
  end

  api :DELETE, "/organizations/:organization_id/host_collections/:id/destroy_content_hosts",
      N_("Destroy a host collection and its systems")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  def destroy_content_hosts
    # this will destroy both the systems contained within the host collection as well as the host collection itself
    system_names = []
    @host_collection.systems.each do |system|
      system_names.push(system.name)
      system.destroy
    end
    @host_collection.destroy

    result = _("Deleted host collection '%{s}' and it's %{n} systems.") % { :s => @host_collection.name, :n => system_names.length.to_s }
    respond_for_destroy :message => result
  end

  api :PUT, "/organizations/:organization_id/host_collections/:id/update_content_hosts",
      N_("Update systems within a host collection")
  param :organization_id, :number, :desc => N_("organization identifier"), :required => true
  param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
  param :host_collection, Hash do
    param :content_view_id, :identifier, N_("id of the content view to set systems to")
    param :environment_id, :identifier, N_("id of the enviornment to set systems to")
  end
  def update_content_hosts
    unless params[:host_collection].blank?
      ActiveRecord::Base.transaction do
        @host_collection.systems.each do |system|
          system.update_attributes!(params[:host_collection])
        end
      end
    end

    respond_for_show
  end

  private

  def find_host_collection
    @host_collection = HostCollection.where(:id => params[:id]).first
    fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % params[:id] if @host_collection.nil?
  end

  def system_uuids_to_ids(ids)
    system_ids = System.where(:uuid => ids).collect { |s| s.id }
    fail Errors::NotFound.new(_("Systems [%s] not found.") % ids.join(',')) if system_ids.blank?
    system_ids
  end

  # to make sure that the changes are reflected to elasticsearch immediately
  # otherwise the index action doesn't have to know about the changes
  def refresh_index
    HostCollection.index.refresh if Katello.config.use_elasticsearch
  end

end
end
