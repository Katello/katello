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
    before_filter :load_search_service, :only => [:index, :systems]

    wrap_parameters :include => (HostCollection.attribute_names + %w(system_ids))

    def_param_group :host_collection do
      param :system_ids, Array, :required => false, :desc => N_("List of content host uuids to be in the host collection")
      param :description, String
      param :max_content_hosts, Integer, :desc => N_("Maximum number of content hosts in the host collection")
      param :unlimited_content_hosts, :bool, :desc => N_("Whether or not the host collection may have unlimited content hosts")
    end

    api :GET, "/host_collections/:id", N_("Show a host collection")
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    def show
      respond
    end

    api :GET, "/host_collections", N_("List host collections")
    api :GET, "/organizations/:organization_id/host_collections", N_("List host collections within an organization")
    api :GET, "/activation_keys/:activation_key_id/host_collections", N_("List host collections in an activation key")
    api :GET, "/systems/:system_id/host_collections", N_("List host collections containing a content host"), :deprecated => true
    param_group :search, Api::V2::ApiController
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("host collection name to filter by")
    param :activation_key_id, :identifier, :desc => N_("activation key identifier")
    param :system_id, :identifier, :desc => N_("system identifier")
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

    api :POST, "/host_collections", N_("Create a host collection")
    api :POST, "/organizations/:organization_id/host_collections", N_("Create a host collection")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :system_uuids, Array, :required => false, :desc => N_("List of content host uuids to replace the content hosts in host collection")
    param :name, String, :required => true, :desc => N_("Host Collection name")
    param_group :host_collection
    def create
      @host_collection = HostCollection.new(host_collection_params_with_system_uuids)
      @host_collection.organization = @organization
      @host_collection.save!
      respond
    end

    api :PUT, "/host_collections/:id", N_("Update a host collection")
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    param :system_uuids, Array, :required => false, :desc => N_("List of content host uuids to be in the host collection")
    param :name, String, :required => false, :desc => N_("Host Collection name")
    param_group :host_collection
    def update
      @host_collection.update_attributes!(host_collection_params_with_system_uuids)
      respond
    end

    # TODO: switch to systems controller index w/ @adprice pull-request
    api :GET, "/host_collections/:id/systems", N_("List content hosts in the host collection"), :deprecated => true
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    def systems
      options = {
        :filters       => [{:term => {:host_collection_ids => @host_collection.id }}],
        :load_records? => true
      }
      respond_for_index(:collection => item_search(System, params, options))
    end

    api :PUT, "/host_collections/:id/add_systems", N_("Add content host to the host collection"), :deprecated => true
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    param :system_ids, Array, :desc => N_("Array of content host ids")
    def add_systems
      ids = System.uuids_to_ids(params[:system_ids])
      @systems = System.editable.where(:id => ids)
      @editable_systems = @systems.editable
      @host_collection.system_ids = (@host_collection.system_ids + @editable_systems.collect { |s| s.id }).uniq
      @host_collection.save!
      System.index.refresh

      messages = format_bulk_action_messages(
          :success    => _("Successfully added %s Content Host(s)."),
          :error      => _("You were not allowed to add %s"),
          :models     => @systems,
          :authorized => @editable_systems
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :PUT, "/host_collections/:id/remove_systems", N_("Remove content hosts from the host collection"), :deprecated => true
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    param :system_ids, Array, :desc => N_("Array of content host ids")
    def remove_systems
      ids = System.uuids_to_ids(params[:system_ids])
      @systems = System.editable.where(:id => ids)
      @editable_systems = @systems.editable
      @host_collection.system_ids = (@host_collection.system_ids - @editable_systems.collect { |s| s.id }).uniq
      @host_collection.save!
      System.index.refresh

      messages = format_bulk_action_messages(
          :success    => _("Successfully removed %s Content Host(s)."),
          :error      => _("You were not allowed to sync %s"),
          :models     => @systems,
          :authorized => @editable_systems
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :DELETE, "/host_collections/:id", N_("Destroy a host collection")
    param :id, :identifier, :desc => N_("Id of the host collection"), :required => true
    def destroy
      @host_collection.destroy
      respond_for_destroy
    end

    api :POST, "/host_collections/:id/copy", N_("Make copy of a host collection")
    param :id, :identifier, :desc => N_("ID of the host collection"), :required => true
    param :name, String, :required => true, :desc => N_("New host collection name")
    def copy
      new_host_collection                           = HostCollection.new
      new_host_collection.name                      = params[:host_collection][:name]
      new_host_collection.organization              = @host_collection.organization
      new_host_collection.description               = @host_collection.description
      new_host_collection.max_content_hosts         = @host_collection.max_content_hosts
      new_host_collection.unlimited_content_hosts   = @host_collection.unlimited_content_hosts
      new_host_collection.systems                   = @host_collection.systems
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
      find_organization
      ids = HostCollection.readable.where(:organization_id => @organization.id).pluck("#{Katello::HostCollection.table_name}.id")
      filters = [:terms => {:id => ids}]
      filters << {:term => {:name => params[:name]}} if params[:name]

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

    def host_collection_params
      attrs = [:name, :description, :max_content_hosts, :unlimited_content_hosts, { :system_ids => [] }]
      params.fetch(:host_collection).permit(*attrs)
    end

    def host_collection_params_with_system_uuids
      result = host_collection_params
      if params['system_uuids']
        systems_from_uuid = System.uuids_to_ids(params['system_uuids'])
        result['system_ids'] = result['system_ids'] ?  result['system_ids'] + systems_from_uuid : systems_from_uuid
      end
      result[:max_content_hosts] = nil if params[:unlimited_content_hosts]
      result
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
