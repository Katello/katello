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
  class Api::V2::HostCollectionsController <  Api::V2::ApiController

    before_filter :find_host_collection, :only => [:copy, :show, :update, :destroy, :destroy_systems,
                                                   :add_systems, :remove_systems, :systems,
                                                   :add_activation_keys, :remove_activation_keys]
    before_filter :find_activation_key
    before_filter :find_system
    before_filter :find_optional_organization, :only => [:index]
    before_filter :find_organization, :only => [:create]
    before_filter :authorize
    before_filter :load_search_service, :only => [:index, :systems]

    def rules
      any_readable         = lambda { @organization && HostCollection.any_readable?(@organization) }
      read_perm            = lambda { @host_collection.readable? }
      edit_perm            = lambda { @host_collection.editable? }
      create_perm          = lambda { HostCollection.creatable?(@organization) }
      destroy_perm         = lambda { @host_collection.deletable? }
      { :index           => any_readable,
        :show            => read_perm,
        :systems         => read_perm,
        :create          => create_perm,
        :copy            => create_perm,
        :update          => edit_perm,
        :destroy         => destroy_perm,
        :add_systems     => edit_perm,
        :remove_systems  => edit_perm,
        :add_activation_keys    => edit_perm,
        :remove_activation_keys => edit_perm
      }
    end

    def_param_group :host_collection do
      param :name, String, :required => true, :desc => "Host Collection name"
      param :system_ids, Array, :required => false, :desc => "List of system uuids to be in the host collection"
      param :description, String
      param :max_content_hosts, Integer, :desc => "Maximum number of content hosts in the host collection"
    end

    api :GET, "/host_collections/:id", "Show a host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    def show
      respond
    end

    api :GET, "/host_collections", "List host collections"
    api :GET, "/organizations/:organization_id/host_collections"
    api :GET, "/activation_keys/:activation_key_id/host_collections"
    api :GET, "/systems/:system_id/host_collections"
    param_group :search, Api::V2::ApiController
    param :organization_id, :number, :desc => "organization identifier", :required => true
    param :name, String, :desc => "host collection name to filter by"
    param :activation_key_id, :identifier, :desc => "activation key identifier"
    param :system_id, :identifier, :desc => "system identifier"
    def index
      subscriptions = if @system
                        filter_system
                      elsif @activation_key
                        filter_activation_key
                      else
                        filter_organization
                      end

      respond_for_index(:collection => subscriptions)
    end

    api :POST, "/host_collections", "Create a host collection"
    api :POST, "/organizations/:organization_id/host_collections", "Create a host collection"
    param :organization_id, :number, :desc => "organization identifier", :required => true
    param_group :host_collection
    def create
      if host_collection_params[:system_ids].present?
        params[:host_collection][:system_ids] = system_ids_to_uuids(params[:host_collection][:system_ids])
      end

      @host_collection = HostCollection.new(host_collection_params)
      @host_collection.organization = @organization
      @host_collection.save!
      respond
    end

    api :PUT, "/host_collections/:id", "Update a host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    param_group :host_collection
    def update
      if host_collection_params[:system_ids].present?
        params[:host_collection][:system_ids] = system_ids_to_uuids(params[:host_collection][:system_ids])
      end

      @host_collection.update_attributes(host_collection_params)
      respond
    end

    # TODO: switch to systems controller index w/ @adprice pull-request
    api :GET, "/host_collections/:id/systems", "List systems in the host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    def systems
      options = {
          :filters       => [{:term => {:host_collection_ids => @host_collection.id }}],
          :load_records? => true
      }
      respond_for_index(:collection => item_search(System, params, options))
    end

    api :PUT, "/host_collections/:id/add_systems", "Add systems to the host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    param :system_ids, Array, :desc => "Array of system ids"
    def add_systems
      ids = system_uuids_to_ids(params[:system_ids])
      @systems = System.readable(@host_collection.organization).where(:id => ids)
      @host_collection.system_ids = (@host_collection.system_ids + @systems.collect { |s| s.id }).uniq
      @host_collection.save!
      System.index.refresh
      respond_for_index(:collection => @host_collection.systems, :template => :delta_systems)
    end

    api :PUT, "/host_collections/:id/remove_systems", "Remove systems from the host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    param :system_ids, Array, :desc => "Array of system ids"
    def remove_systems
      ids = system_uuids_to_ids(params[:system_ids])
      system_ids = System.readable(@host_collection.organization).where(:id => ids).collect { |s| s.id }
      @host_collection.system_ids = (@host_collection.system_ids - system_ids).uniq
      @host_collection.save!
      System.index.refresh
      respond_for_index(:collection => @host_collection.systems, :template => :delta_systems)
    end

    api :PUT, "/host_collections/:id/add_activation_keys", "Add activation keys to the host collection"
    param :id, :identifier, :desc => "ID of the host collection", :required => true
    param :activation_key_ids, Array, :desc => "Array of activation key IDs"
    def add_activation_keys
      ids = params[:activation_key_ids]
      @activation_keys = ActivationKey.readable(@host_collection.organization).where(:id => ids)
      @host_collection.activation_key_ids = (@host_collection.activation_key_ids + @activation_keys.collect { |activation_key| activation_key.id }).uniq
      @host_collection.save!
      ActivationKey.index.refresh
      respond_for_index(:collection => @host_collection.activation_keys, :template => :delta_activation_keys)
    end

    api :PUT, "/host_collections/:id/remove_activation_keys", "Remove activation keys from the host collection"
    param :id, :identifier, :desc => "ID of the activation key host collection", :required => true
    param :activation_key_ids, Array, :desc => "Array of activation key IDs"
    def remove_activation_keys
      ids = params[:activation_key_ids]
      activation_key_ids = ActivationKey.readable(@host_collection.organization).where(:id => ids).collect { |s| s.id }
      @host_collection.activation_key_ids = (@host_collection.activation_key_ids - activation_key_ids).uniq
      @host_collection.save!
      ActivationKey.index.refresh
      respond_for_index(:collection => @host_collection.activation_keys, :template => :delta_activation_keys)
    end

    api :GET, "/host_collections/:id/history", "History of jobs performed on a host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    # TODO: v2 update
    def history
      super
    end

    api :GET, "/host_collections/:id/history", "History of a job performed on a host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    param :job_id, :identifier, :desc => "Id of a job for filtering"
    # TODO: v2 update
    def history_show
      super
    end

    api :DELETE, "/host_collections/:id", "Destroy a host collection"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    # TODO: v2 update
    def destroy
      @host_collection.destroy
      respond_for_destroy
    end

    api :DELETE, "/host_collections/:id/destroy_systems", "Destroy a host collection nad contained systems"
    param :id, :identifier, :desc => "Id of the host collection", :required => true
    # TODO: v2 update
    def destroy_systems
      super
    end

    api :POST, "/host_collections/:id/copy", "Make copy of a host collection"
    param :id, :identifier, :desc => "ID of the host collection", :required => true
    param :name, String, :required => true, :desc => "New host collection name"
    def copy
      new_host_collection                   = HostCollection.new
      new_host_collection.name              = params[:host_collection][:name]
      new_host_collection.organization      = @host_collection.organization
      new_host_collection.description       = @host_collection.description
      new_host_collection.max_content_hosts = @host_collection.max_content_hosts
      new_host_collection.systems           = @host_collection.systems
      new_host_collection.save!
      respond_for_create :resource => new_host_collection
    end

    private

    def filter_system
      filters = [:terms => {:id => @system.host_collections.pluck("#{Katello::HostCollection.table_name}.id")}]

      options = {
          :filters       => filters,
          :load_records? => true
      }
      item_search(HostCollection, params, options)
    end

    def filter_activation_key
      filters = [:terms => {:id => @activation_key.host_collections.pluck("#{Katello::HostCollection.table_name}.id")}]

      options = {
          :filters       => filters,
          :load_records? => true
      }
      item_search(HostCollection, params, options)
    end

    def filter_organization
      filters = [:terms => {:id => HostCollection.readable(@organization).pluck("#{Katello::HostCollection.table_name}.id")}]
      filters << {:term => {:name => params[:name].downcase}} if params[:name]

      options = {
          :filters       => filters,
          :load_records? => true
      }
      item_search(HostCollection, params, options)
    end

    def find_host_collection
      @organization = @system.organization if @system
      @organization = @activation_key.organization if @activation_key
      @host_collection = HostCollection.where(:id => params[:id]).first
      fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % params[:id] if @host_collection.nil?
    end

    def system_uuids_to_ids(ids)
      system_ids = System.where(:uuid => ids).collect { |s| s.id }
      fail Errors::NotFound.new(_("Systems [%s] not found.") % ids.join(',')) if system_ids.blank?
      system_ids
    end

    def host_collection_params
      params.require(:host_collection).permit(:name, :description, :max_content_hosts, :system_ids)
    end

    def find_system
      @system = System.find_by_uuid!(params[:system_id]) if params[:system_id]
      @organization = @system.organization if @system
    end

    def find_activation_key
      @activation_key = ActivationKey.find_by_id!(params[:activation_key_id]) if params[:activation_key_id]
      @organization = @activation_key.organization if @activation_key
    end

  end
end
