module Katello
  class Api::V2::HostCollectionsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    before_action :find_authorized_katello_resource, :only => [
      :copy,
      :show,
      :update,
      :destroy,
      :add_hosts,
      :remove_hosts,
      :hosts,
    ]
    before_action :find_readable_activation_key, :only => [:index]
    before_action :find_editable_host, :only => [:index]
    before_action :find_optional_organization, :only => [:index]
    before_action :find_organization, :only => [:create, :auto_complete_search]

    wrap_parameters :include => (HostCollection.attribute_names + %w(host_ids))

    def_param_group :host_collection do
      param :description, String
      param :host_ids, Array, :required => false, :desc => N_("List of host ids to replace the hosts in host collection")
      param :max_hosts, Integer, :desc => N_("Maximum number of hosts in the host collection")
      param :unlimited_hosts, :bool, :desc => N_("Whether or not the host collection may have unlimited hosts")
    end

    api :GET, "/host_collections/:id", N_("Show a host collection")
    param :id, :number, :desc => N_("Id of the host collection"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def show
      respond(:resource => @host_collection)
    end

    api :GET, "/host_collections", N_("List host collections")
    api :GET, "/organizations/:organization_id/host_collections", N_("List host collections within an organization")
    api :GET, "/activation_keys/:activation_key_id/host_collections", N_("List host collections in an activation key")
    param_group :search, Api::V2::ApiController
    param :organization_id, :number, :desc => N_("organization identifier")
    param :name, String, :desc => N_("host collection name to filter by")
    param :activation_key_id, :identifier, :desc => N_("activation key identifier")
    param :host_id, :number, :desc => N_("Filter products by host id")
    param :available_for, String, :required => false,
          :desc => N_("Interpret specified object to return only Host Collections that can be associated with specified object. The value 'host' is supported.")
    add_scoped_search_description_for(HostCollection)
    def index
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc))
    end

    def index_relation
      if @host
        query = @host.host_collections

        if params[:available_for] == "host"
          query = Katello::HostCollection.readable.where(:organization_id => @organization.id)

          if @host.host_collections.count > 0
            query = query.where("#{Katello::HostCollection.table_name}.id NOT IN (?)", @host.host_collection_ids)
          end
        end
      elsif @activation_key
        query = @activation_key.host_collections
      elsif @organization
        query = HostCollection.readable.where(:organization_id => @organization.id)
      else
        query = HostCollection.readable
      end
      query = query.where(:name => params[:name]) if params[:name]
      query
    end

    api :POST, "/host_collections", N_("Create a host collection")
    api :POST, "/organizations/:organization_id/host_collections", N_("Create a host collection")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :required => true, :desc => N_("Host Collection name")
    param_group :host_collection
    def create
      @host_collection = HostCollection.new(host_collection_params_with_host_ids)
      @host_collection.organization = @organization
      @host_collection.save!
      respond_for_create(:resource => @host_collection)
    end

    api :PUT, "/host_collections/:id", N_("Update a host collection")
    param :id, :number, :desc => N_("Id of the host collection"), :required => true
    param :name, String, :required => false, :desc => N_("Host Collection name")
    param_group :host_collection
    def update
      @host_collection.update!(host_collection_params_with_host_ids)
      respond_for_show(:resource => @host_collection)
    end

    api :PUT, "/host_collections/:id/add_hosts", N_("Add host to the host collection")
    param :id, :number, :desc => N_("Id of the host collection"), :required => true
    param :host_ids, Array, :desc => N_("Array of host ids")
    def add_hosts
      host_ids = params[:host_ids].map(&:to_i)

      @hosts = ::Host::Managed.where(id: host_ids)
      @editable_hosts = @hosts.authorized(:edit_hosts)

      already_added_host_ids = @host_collection.host_ids & host_ids
      unfound_host_ids = host_ids - @hosts.pluck(:id)

      @host_collection.host_ids = (@host_collection.host_ids +
                                   @editable_hosts.pluck(:id)).uniq
      @host_collection.save!

      messages = format_bulk_action_messages(
          :success    => _("Successfully added %s Host(s)."),
          :error      => _("You were not allowed to add %s"),
          :models     => @hosts.pluck(:id) - already_added_host_ids,
          :authorized => @editable_hosts.pluck(:id) - already_added_host_ids
      )

      already_added_host_ids.each do |host_id|
        messages[:error] << _("Host with ID %s already exists in the host collection.") % host_id
      end

      unfound_host_ids.each do |host_id|
        messages[:error] << _("Host with ID %s not found.") % host_id
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :PUT, "/host_collections/:id/remove_hosts", N_("Remove hosts from the host collection")
    param :id, :number, :desc => N_("Id of the host collection"), :required => true
    param :host_ids, Array, :desc => N_("Array of host ids")
    def remove_hosts
      host_ids = params[:host_ids].map(&:to_i)

      @hosts = ::Host::Managed.where(id: host_ids)
      @editable_hosts = @hosts.authorized(:edit_hosts)

      already_removed_host_ids = @hosts.pluck(:id) - @host_collection.host_ids
      unfound_host_ids = host_ids - @hosts.pluck(:id)

      @host_collection.host_ids -= @editable_hosts.pluck(:id)
      @host_collection.save!

      messages = format_bulk_action_messages(
          :success    => _("Successfully removed %s Host(s)."),
          :error      => _("You were not allowed to sync %s"),
          :models     => @hosts.pluck(:id) - already_removed_host_ids,
          :authorized => @editable_hosts.pluck(:id) - already_removed_host_ids
      )

      already_removed_host_ids.each do |host_id|
        messages[:error] << _("Host with ID %s does not exist in the host collection.") % host_id
      end

      unfound_host_ids.each do |host_id|
        messages[:error] << _("Host with ID %s not found.") % host_id
      end

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :DELETE, "/host_collections/:id", N_("Destroy a host collection")
    param :id, :number, :desc => N_("Id of the host collection"), :required => true
    def destroy
      @host_collection.destroy
      respond_for_destroy
    end

    api :POST, "/host_collections/:id/copy", N_("Make copy of a host collection")
    param :id, :number, :desc => N_("ID of the host collection"), :required => true
    param :name, String, :required => true, :desc => N_("New host collection name")
    def copy
      new_host_collection                           = HostCollection.new
      new_host_collection.name                      = params[:host_collection][:name]
      new_host_collection.organization              = @host_collection.organization
      new_host_collection.description               = @host_collection.description
      new_host_collection.max_hosts                 = @host_collection.max_hosts
      new_host_collection.unlimited_hosts           = @host_collection.unlimited_hosts
      new_host_collection.hosts                     = @host_collection.hosts
      new_host_collection.save!
      respond_for_create :resource => new_host_collection
    end

    private

    def host_collection_params
      attrs = [:name,
               :description,
               :max_hosts,
               :unlimited_hosts,
               { :host_ids => [] },
              ]
      params.fetch(:host_collection).permit(*attrs)
    end

    def host_collection_params_with_host_ids
      result = host_collection_params
      if params[:unlimited_hosts]
        result[:max_hosts] = nil
      elsif params[:max_hosts]
        result[:unlimited_hosts] = false
      end
      result
    end

    def find_editable_host
      @host = resource_finder(::Host::Managed.authorized("edit_hosts"), params[:host_id]) if params[:host_id]
      @organization = @host.organization if @host
    end

    def find_readable_activation_key
      @activation_key = ActivationKey.readable.find_by(:id => params[:activation_key_id]) if params[:activation_key_id]
      if params[:activation_key_id] && @activation_key.nil?
        throw_resource_not_found(name: 'activation_key', id: params[:activation_key_id])
      else
        @organization = @activation_key&.organization
      end
    end
  end
end
