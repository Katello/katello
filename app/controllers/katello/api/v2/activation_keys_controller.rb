module Katello
  class Api::V2::ActivationKeysController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    include Katello::Concerns::Api::V2::ContentOverridesController
    before_action :verify_presence_of_organization_or_environment, :only => [:index]
    before_action :find_environment, :only => [:index, :create, :update]
    before_action :find_optional_organization, :only => [:index, :create, :show]
    before_action :find_content_view, :only => [:index]
    before_action :find_activation_key, :only => [:show, :update, :destroy, :available_releases, :copy, :product_content,
                                                  :available_host_collections, :add_host_collections, :remove_host_collections,
                                                  :content_override, :add_subscriptions, :remove_subscriptions,
                                                  :subscriptions]
    before_action :authorize

    wrap_parameters :include => (ActivationKey.attribute_names + %w(host_collection_ids service_level auto_attach content_view_environment))

    api :GET, "/activation_keys", N_("List activation keys")
    api :GET, "/environments/:environment_id/activation_keys"
    api :GET, "/organizations/:organization_id/activation_keys"
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :environment_id, :identifier, :desc => N_("environment identifier")
    param :content_view_id, :identifier, :desc => N_("content view identifier")
    param :name, String, :desc => N_("activation key name to filter by")
    param_group :search, Api::V2::ApiController
    def index
      activation_key_includes = [:content_view, :environment, :host_collections, :organization]
      respond(:collection => scoped_search(index_relation.uniq, :name, :asc, :includes => activation_key_includes))
    end

    api :POST, "/activation_keys", N_("Create an activation key")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name"), :required => true
    param :description, String, :desc => N_("description")
    param :environment, Hash, :desc => N_("environment")
    param :environment_id, :identifier, :desc => N_("environment id")
    param :content_view_id, :identifier, :desc => N_("content view id")
    param :max_hosts, :number, :desc => N_("maximum number of registered content hosts")
    param :unlimited_hosts, :bool, :desc => N_("can the activation key have unlimited hosts")
    def create
      @activation_key = ActivationKey.new(activation_key_params) do |activation_key|
        activation_key.environment = @environment if @environment
        activation_key.organization = @organization
        activation_key.user = current_user
      end
      sync_task(::Actions::Katello::ActivationKey::Create, @activation_key)
      @activation_key.reload
      respond(:resource => @activation_key)
    end

    api :PUT, "/activation_keys/:id", N_("Update an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name"), :required => false
    param :description, String, :desc => N_("description")
    param :environment_id, :identifier, :desc => N_("environment id")
    param :content_view_id, :identifier, :desc => N_("content view id")
    param :max_hosts, :number, :desc => N_("maximum number of registered content hosts")
    param :unlimited_hosts, :bool, :desc => N_("can the activation key have unlimited hosts")
    param :release_version, String, :desc => N_("content release version")
    param :service_level, String, :desc => N_("service level")
    param :auto_attach, :bool, :desc => N_("auto attach subscriptions upon registration")
    def update
      sync_task(::Actions::Katello::ActivationKey::Update, @activation_key, activation_key_params)
      respond_for_show(:resource => @activation_key)
    end

    api :DELETE, "/activation_keys/:id", N_("Destroy an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    def destroy
      task = sync_task(::Actions::Katello::ActivationKey::Destroy,
                       @activation_key)
      respond_for_async(:resource => task)
    end

    api :GET, "/activation_keys/:id", N_("Show an activation key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def show
      respond(:resource => @activation_key)
    end

    api :POST, "/activation_keys/:id/copy", N_("Copy an activation key")
    param :new_name, String, :desc => N_("Name of new activation key"), :required => true
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def copy
      fail HttpErrors::BadRequest, _("New name cannot be blank") unless params[:new_name]
      @new_activation_key = @activation_key.copy(params[:new_name])
      @new_activation_key.user = current_user
      sync_task(::Actions::Katello::ActivationKey::Create, @new_activation_key)
      @new_activation_key.reload
      sync_task(::Actions::Katello::ActivationKey::Update, @new_activation_key,
                  :service_level   => @activation_key.service_level,
                  :release_version => @activation_key.release_version,
                  :auto_attach     => @activation_key.auto_attach
               )
      @activation_key.content_overrides.each do |content|
        @new_activation_key.set_content_override(content['contentLabel'], content[:name], content[:value])
      end
      @activation_key.pools.each do |pool|
        @new_activation_key.subscribe(pool[:id])
      end
      respond_for_show(:resource => @new_activation_key)
    end

    api :GET, "/activation_keys/:id/host_collections/available", N_("List host collections the activation key does not belong to")
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => N_("host collection name to filter by")
    def available_host_collections
      table_name = HostCollection.table_name
      host_collection_ids = @activation_key.host_collections.pluck("#{table_name}.id")

      scoped = HostCollection.readable
      scoped = scoped.where("#{table_name}.id NOT IN (?)", host_collection_ids) if host_collection_ids.present?
      scoped = scoped.where(:organization_id => @activation_key.organization)
      scoped = scoped.where(:name => params[:name]) if params[:name]

      respond_for_index(:collection => scoped_search(scoped, :name, :asc, :resource_class => HostCollection))
    end

    api :GET, "/activation_keys/:id/releases", N_("Show release versions available for an activation key")
    param :id, String, :desc => N_("ID of the activation key"), :required => true
    def available_releases
      response = {
        :results => @activation_key.available_releases,
        :total => @activation_key.available_releases.size,
        :subtotal => @activation_key.available_releases.size
      }
      respond_for_index :collection => response
    end

    api :GET, "/activation_keys/:id/product_content", N_("Show content available for an activation key")
    param :id, String, :desc => N_("ID of the activation key"), :required => true
    param :content_access_mode_all, :bool, :desc => N_("Get all content available, not just that provided by subscriptions")
    param :content_access_mode_env, :bool, :desc => N_("Limit content to just that available in the activation key's content view version")
    def product_content
      content_access_mode_all = ::Foreman::Cast.to_bool(params[:content_access_mode_all])
      content_access_mode_env = ::Foreman::Cast.to_bool(params[:content_access_mode_env])
      content = @activation_key.available_content(content_access_mode_all, content_access_mode_env)
      response = {
        :results => content,
        :total => content.size,
        :subtotal => content.size
      }
      respond_for_index :collection => response
    end

    api :POST, "/activation_keys/:id/host_collections"
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection IDs to associate with activation key")
    def add_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids + ids).uniq
      @activation_key.save!
      respond_for_show(:resource => @activation_key)
    end

    api :PUT, "/activation_keys/:id/host_collections"
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection IDs to disassociate from the activation key")
    def remove_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids - ids).uniq
      @activation_key.save!
      respond_for_show(:resource => @activation_key)
    end

    api :PUT, "/activation_keys/:id/add_subscriptions", N_("Attach a subscription")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :subscription_id, :number, :desc => N_("Subscription identifier"), :required => false
    param :quantity, :number, :desc => N_("Quantity of this subscription to add"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => false
    end
    def add_subscriptions
      if params[:subscriptions]
        params[:subscriptions].each { |subscription| @activation_key.subscribe(subscription[:id], subscription[:quantity]) }
      elsif params[:subscription_id]
        @activation_key.subscribe(params[:subscription_id], params[:quantity])
      end

      respond_for_index(:collection => subscription_index, :template => 'subscriptions')
    end

    api :PUT, "/activation_keys/:id/remove_subscriptions", N_("Unattach a subscription")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :subscription_id, String, :desc => N_("Subscription ID"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
    end
    def remove_subscriptions
      if params[:subscriptions]
        params[:subscriptions].each { |subscription| @activation_key.unsubscribe(subscription[:id]) }
      elsif params[:subscription_id]
        @activation_key.unsubscribe(params[:subscription_id])
      end

      respond_for_index(:collection => subscription_index, :template => 'subscriptions')
    end

    api :PUT, "/activation_keys/:id/content_override", N_("Override content for activation_key")
    param :id, :identifier, :desc => N_("ID of the activation key"), :required => true
    param :content_override, Hash, :desc => N_("Content override parameters"), :deprecated => true do
      param :content_label, String, :desc => N_("Label of the content"), :required => true
      param :value, String, :desc => N_("Override to a boolean value or 'default'"), :required => true
    end
    param :content_overrides, Array, :desc => N_("Array of Content override parameters") do
      param :content_label, String, :desc => N_("Label of the content"), :required => true
      param :value, String, :desc => N_("Override value. Provide a boolean value if name is 'enabled'"), :required => false
      param :name, String, :desc => N_("Override key or name. Note if name is not provided the default name will be 'enabled'"), :required => false
      param :remove, :bool, :desc => N_("Set true to remove an override and reset it to 'default'"), :required => false
    end
    def content_override
      content_overrides = []
      if params[:content_override]
        ::Foreman::Deprecation.api_deprecation_warning("The parameter content_override will be removed in Katello 3.5. Please update to use the content_overrides parameter.")
        content_override_params = {:content_label => params[:content_override][:content_label]}
        value = params[:content_override][:value]
        if value == "default"
          content_override_params[:remove] = true
        elsif value
          content_override_params[:value] = ::Foreman::Cast.to_bool(value)
        end
        content_overrides << content_override_params
      elsif params[:content_overrides]
        content_overrides = params[:content_overrides]
      end

      content_override_values = content_overrides.map do |override_params|
        validate_content_overrides_enabled(override_params)
      end
      @activation_key.set_content_overrides(content_override_values)
      respond_for_show(:resource => @activation_key)
    end

    def index_relation
      activation_keys = ActivationKey.readable
      activation_keys = activation_keys.where(:name => params[:name]) if params[:name]
      activation_keys = activation_keys.where(:organization_id => @organization) if @organization
      activation_keys = activation_keys.where(:environment_id => @environment) if @environment
      activation_keys = activation_keys.where(:content_view_id => @content_view) if @content_view
      activation_keys
    end

    def find_activation_key
      @activation_key = ActivationKey.find(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % params[:id] if @activation_key.nil?
      @activation_key
    end

    private

    def subscription_index
      subs = @activation_key.subscriptions
      subscriptions = {
        :results => subs,
        :subtotal => subs.count,
        :total => subs.count,
        :page => 1,
        :per_page => subs.count
      }
      subscriptions
    end

    def find_environment
      environment_id = params[:environment_id]
      environment_id = params[:environment][:id] if !environment_id && params[:environment]
      return unless environment_id

      @environment = KTEnvironment.find(environment_id)
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @organization = @environment.organization
      @environment
    end

    def find_host_collections
      ids = params[:activation_key][:host_collection_ids] if params[:activation_key]
      @host_collections = []
      if ids
        ids.each do |host_collection_id|
          host_collection = HostCollection.find(host_collection_id)
          fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % host_collection_id if host_collection.nil?
          @host_collections << host_collection
        end
      end
    end

    def verify_presence_of_organization_or_environment
      return if params.key?(:organization_id) || params.key?(:environment_id)
      fail HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
    end

    def find_content_view
      if params.include?(:content_view_id)
        cv_id = params[:content_view_id]
        @content_view = ContentView.find_by(:id => cv_id)
        fail HttpErrors::NotFound, _("Couldn't find content view '%s'") % cv_id if @content_view.nil?
      end
    end

    def activation_key_params
      key_params = params.require(:activation_key).permit(:name,
                                                          :description,
                                                          :environment_id,
                                                          :organization_id,
                                                          :content_view_id,
                                                          :release_version,
                                                          :service_level,
                                                          :auto_attach,
                                                          :max_hosts,
                                                          :unlimited_hosts,
                                                          # For deep_munge; Remove for Rails 5
                                                          :host_collection_ids,
                                                          :content_overrides => [],
                                                          :host_collection_ids => [])

      key_params[:environment_id] = params[:environment][:id] if params[:environment].try(:[], :id)
      key_params[:content_view_id] = params[:content_view][:id] if params[:content_view].try(:[], :id)
      unlimited = params[:activation_key].try(:[], :unlimited_hosts)
      max_hosts = params[:activation_key].try(:[], :max_hosts)

      if unlimited && max_hosts
        key_params[:unlimited_hosts] = true
        key_params[:max_hosts] = nil
      else
        key_params[:unlimited_hosts] = false if max_hosts
        key_params[:max_hosts] = nil if unlimited
      end

      key_params
    end
  end
end
