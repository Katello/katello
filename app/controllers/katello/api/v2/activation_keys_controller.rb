module Katello
  class Api::V2::ActivationKeysController < Api::V2::ApiController  # rubocop:disable Metrics/ClassLength
    include Katello::Concerns::FilteredAutoCompleteSearch
    include Katello::Concerns::Api::V2::ContentOverridesController
    include Katello::Concerns::Api::V2::MultiCVParamsHandling
    before_action :verify_presence_of_organization_or_environment, :only => [:index]
    before_action :find_optional_organization, :only => [:index, :create, :show]
    before_action :find_authorized_katello_resource, :only => [:show, :update, :destroy, :available_releases,
                                                               :available_host_collections, :add_host_collections, :remove_host_collections,
                                                               :content_override, :add_subscriptions, :remove_subscriptions,
                                                               :subscriptions]
    before_action :find_content_view_environments, :only => [:create, :update]
    before_action :verify_simple_content_access_disabled, :only => [:add_subscriptions]
    before_action :validate_release_version, :only => [:create, :update]

    wrap_parameters :include => (ActivationKey.attribute_names + %w(host_collection_ids service_level auto_attach purpose_role purpose_usage purpose_addons content_view_environments))

    def_param_group :activation_key do
      param :organization_id, :number, :desc => N_("organization identifier"), :required => true
      param :description, String, :desc => N_("description")
      param :max_hosts, :number, :desc => N_("maximum number of registered content hosts")
      param :unlimited_hosts, :bool, :desc => N_("can the activation key have unlimited hosts")
      param :release_version, String, :desc => N_("content release version")
      param :service_level, String, :desc => N_("service level")
      param :auto_attach, :bool, :desc => N_("auto attach subscriptions upon registration"), deprecated: true
      param :purpose_usage, String, :desc => N_("Sets the system purpose usage")
      param :purpose_role, String, :desc => N_("Sets the system purpose usage")
      param :purpose_addons, Array, :desc => N_("Sets the system add-ons")

      param :environment, Hash, :desc => N_("Hash containing the Id of the single lifecycle environment to be associated with the activation key."), deprecated: true
      param :content_view_id, Integer, :desc => N_("Id of the single content view to be associated with the activation key.")
      param :environment_id, Integer, :desc => N_("Id of the single lifecycle environment to be associated with the activation key.")
      param :content_view_environments, Array, :desc => N_("Comma-separated list of Candlepin environment names to be associated with the activation key,"\
                                              " in the format of 'lifecycle_environment_label/content_view_label'."\
                                              " Ignored if content_view_environment_ids is specified, or if content_view_id and lifecycle_environment_id are specified."\
                                              " Requires allow_multiple_content_views setting to be on.")
      param :content_view_environment_ids, Array, :desc => N_("Array of content view environment ids to be associated with the activation key."\
                                              " Ignored if content_view_id and lifecycle_environment_id are specified."\
                                              " Requires allow_multiple_content_views setting to be on.")
    end

    api :GET, "/activation_keys", N_("List activation keys")
    api :GET, "/environments/:environment_id/activation_keys"
    api :GET, "/organizations/:organization_id/activation_keys"
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :environment_id, :number, :desc => N_("environment identifier")
    param :content_view_id, :number, :desc => N_("content view identifier")
    param :name, String, :desc => N_("activation key name to filter by")
    param :content_view_environments, Array, :desc => N_("Comma-separated list of Candlepin environment names associated with the activation key,"\
                                            " in the format of 'lifecycle_environment_label/content_view_label'."\
                                            " Ignored if content_view_environment_ids is specified, or if content_view_id and lifecycle_environment_id are specified."\
                                            " Requires allow_multiple_content_views setting to be on.")
    param :content_view_environment_ids, Array, :desc => N_("Array of content view environment ids associated with the activation key. " \
                                            "Ignored if content_view_id and lifecycle_environment_id are specified."\
                                            "Requires allow_multiple_content_views setting to be on.")

    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(ActivationKey)
    def index
      activation_key_includes = [:content_view_environments, :host_collections, :organization]
      respond(:collection => scoped_search(index_relation.distinct, :name, :asc, :includes => activation_key_includes))
    end

    api :POST, "/activation_keys", N_("Create an activation key")
    param :name, String, :desc => N_("name"), :required => true
    param_group :activation_key
    def create
      @activation_key = ActivationKey.new(activation_key_params) do |activation_key|
        activation_key.content_view_environments = @content_view_environments if update_cves?
        activation_key.organization = @organization
        activation_key.user = current_user
      end
      sync_task(::Actions::Katello::ActivationKey::Create, @activation_key, service_level: activation_key_params['service_level'])
      @activation_key.reload

      respond_for_create(:resource => @activation_key)
    end

    api :PUT, "/activation_keys/:id", N_("Update an activation key")
    param_group :activation_key
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :name, String, :desc => N_("name"), :required => false
    def update
      if @content_view_environments.present? || update_cves?
        if single_assignment? && @content_view_environments.length == 1
          @activation_key.assign_single_environment(
            content_view: @content_view_environments.first.content_view,
            lifecycle_environment: @content_view_environments.first.lifecycle_environment
          )
        else
          @activation_key.update!(content_view_environments: @content_view_environments)
        end
      end
      sync_task(::Actions::Katello::ActivationKey::Update, @activation_key, activation_key_params)
      respond_for_show(:resource => @activation_key)
    end

    api :DELETE, "/activation_keys/:id", N_("Destroy an activation key")
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    def destroy
      task = sync_task(::Actions::Katello::ActivationKey::Destroy,
                       @activation_key)
      respond_for_async(:resource => task)
    end

    api :GET, "/activation_keys/:id", N_("Show an activation key")
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    param :show_hosts, :bool, :desc => N_("Show hosts associated to an activation key"), :required => false
    def show
      respond(:resource => @activation_key)
    end

    api :POST, "/activation_keys/:id/copy", N_("Copy an activation key")
    param :new_name, String, :desc => N_("Name of new activation key"), :required => true
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    def copy
      @activation_key = Katello::ActivationKey.readable.find_by(:id => params[:id])
      throw_resource_not_found(name: 'activation_key', id: params[:id]) if @activation_key.nil?

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
      @activation_key.pools.each do |pool|
        @new_activation_key.subscribe(pool[:id])
      end
      @new_activation_key.set_content_overrides(@activation_key.content_overrides) unless @activation_key.content_overrides.blank?
      respond_for_create(:resource => @new_activation_key)
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

    api :POST, "/activation_keys/:id/host_collections"
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection IDs to associate with activation key")
    def add_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids + ids).uniq
      @activation_key.save!
      respond_for_show(:resource => @activation_key)
    end

    api :PUT, "/activation_keys/:id/host_collections"
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection IDs to disassociate from the activation key")
    def remove_host_collections
      ids = activation_key_params[:host_collection_ids]
      @activation_key.host_collection_ids = (@activation_key.host_collection_ids - ids).uniq
      @activation_key.save!
      respond_for_show(:resource => @activation_key)
    end

    def deprecate_entitlement_mode_endpoint
      ::Foreman::Deprecation.api_deprecation_warning(N_("This endpoint is deprecated and will be removed in an upcoming release. Simple Content Access is the only supported content access mode."))
    end

    api :PUT, "/activation_keys/:id/add_subscriptions", N_("Attach a subscription"), deprecated: true
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :subscription_id, :number, :desc => N_("Subscription identifier"), :required => false
    param :quantity, :number, :desc => N_("Quantity of this subscription to add"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => false
    end
    def add_subscriptions
      deprecate_entitlement_mode_endpoint
      if params[:subscriptions]
        params[:subscriptions].each { |subscription| @activation_key.subscribe(subscription[:id], subscription[:quantity]) }
      elsif params[:subscription_id]
        @activation_key.subscribe(params[:subscription_id], params[:quantity])
      end

      respond_for_index(:collection => subscription_index, :template => 'subscriptions')
    end

    api :PUT, "/activation_keys/:id/remove_subscriptions", N_("Unattach a subscription"), deprecated: true
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :subscription_id, String, :desc => N_("Subscription ID"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
    end
    def remove_subscriptions
      deprecate_entitlement_mode_endpoint
      if params[:subscriptions]
        params[:subscriptions].each { |subscription| @activation_key.unsubscribe(subscription[:id]) }
      elsif params[:subscription_id]
        @activation_key.unsubscribe(params[:subscription_id])
      end

      respond_for_index(:collection => subscription_index, :template => 'subscriptions')
    end

    api :PUT, "/activation_keys/:id/content_override", N_("Override content for activation_key")
    param :id, :number, :desc => N_("ID of the activation key"), :required => true
    param :content_overrides, Array, :desc => N_("Array of Content override parameters to be added in bulk") do
      param :content_label, String, :desc => N_("Label of the content"), :required => true
      param :value, String, :desc => N_("Override value. Provide a boolean value if name is 'enabled'"), :required => false
      param :name, String, :desc => N_("Override parameter key or name. Note if name is not provided the default name will be 'enabled'"), :required => false
      param :remove, :bool, :desc => N_("Set true to remove an override and reset it to 'default'"), :required => false
    end
    def content_override
      if params[:content_overrides]
        organization = @activation_key.organization
        specified_labels = []
        content_override_values = params[:content_overrides].map do |override|
          specified_labels << override[:content_label]
          validate_content_overrides_enabled(override)
        end
        specified_labels.uniq!
        existing_labels = organization.contents.where(label: specified_labels).pluck(:label).uniq

        unless specified_labels.size == existing_labels.size
          missing_labels = specified_labels - existing_labels
          msg = "Content label(s) \"#{missing_labels.join(", ")}\" were not found in the Organization \"#{organization}\""
          fail HttpErrors::BadRequest, _(msg)
        end

        @activation_key.set_content_overrides(content_override_values)
      end
      respond_for_show(:resource => @activation_key)
    end

    api :GET, "/activation_keys/:id/product_content", N_("Show content available for an activation key")
    param :id, String, :desc => N_("ID of the activation key"), :required => true
    param :content_access_mode_all, :bool, :desc => N_("Get all content available, not just that provided by subscriptions"), deprecated: true, default: true
    param :content_access_mode_env, :bool, :desc => N_("Limit content to just that available in the activation key's content view version")
    param_group :search, Api::V2::ApiController
    def product_content
      # NOTE: this is just there as a place holder for apipie.
      # The routing would automatically redirect it to repository_sets#index
    end

    def index_relation
      activation_keys = ActivationKey.readable
      activation_keys = activation_keys.where(:name => params[:name]) if params[:name]
      activation_keys = activation_keys.where(:organization_id => @organization) if @organization
      activation_keys = activation_keys.with_content_view_environments(@content_view_environments) if @content_view_environments
      activation_keys = activation_keys.with_content_views(params[:content_view_id]) if params[:content_view_id]
      activation_keys = activation_keys.with_environments(params[:lifecycle_environments]) if params[:lifecycle_environments]
      activation_keys
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

    def find_cve_for_single
      environment_id = params.dig(:environment, :id) || params[:environment_id]
      content_view_id = params.dig(:content_view, :id) || params[:content_view_id]
      if environment_id.blank? || content_view_id.blank?
        fail HttpErrors::BadRequest, _("Environment ID and content view ID must be provided together")
      end
      cve = ::Katello::ContentViewEnvironment.readable.where(environment_id: environment_id,
                                                             content_view_id: content_view_id).first
      if cve.blank?
        fail HttpErrors::NotFound, _("Couldn't find content view environment with content view ID '%{cv}'"\
                                    " and environment ID '%{env}'") % { cv: content_view_id, env: environment_id }
      end
      @content_view_environments = [cve]
    end

    def params_likely_not_from_angularjs?
      # AngularJS sends back the activation key's existing API response values.
      # A side effect of this is that when it sends params[:content_view_environments] or params[:content_view_environment_ids],
      # it incorrectly sends the nested objects from the rabl response, instead of the required single comma-separated string of Candlepin names.
      # This would cause fetch_content_view_environments to fail.
      # Therefore, we need a way to (a) detect if the request is from AngularJS, and (b) avoid trying to handle the nested objects as if they were strings.
      # So we look at params[:multi_content_view_environment]. This is a computed value, not meant to be submitted as part of an update request.
      # If it's true or false, it's likely AngularJS.
      # And if the key is omitted, it's likely from Hammer or API, so it's safe to proceed.
      !params.key?(:multi_content_view_environment)
    end

    def find_content_view_environments
      @content_view_environments = []
      if params[:environment_id] || params[:environment]
        find_cve_for_single
      elsif params_likely_not_from_angularjs? && (params[:content_view_environments] || params[:content_view_environment_ids])
        @content_view_environments = ::Katello::ContentViewEnvironment.fetch_content_view_environments(
          labels: params[:content_view_environments],
          ids: params[:content_view_environment_ids],
          organization: @organization || @activation_key&.organization)
        if @content_view_environments.blank?
          handle_errors(labels: params[:content_view_environments],
          ids: params[:content_view_environment_ids])
        end
      end
      handle_blank_cve_params
      @organization ||= @content_view_environments.first&.organization
    end

    def handle_blank_cve_params
      if params.key?(:environment) && params.key?(:content_view)
        return # AngularJS sends nested environment and content_view params, but with blank _id values
      end
      # Activation keys do not require CVEs to be associated. So it's possible the user intends to clear them.
      if params.key?(:environment_id) && params[:environment_id].blank? && params.key?(:content_view_id) && params[:content_view_id].blank?
        @content_view_environments = []
      elsif params.key?(:content_view_environments) && params[:content_view_environments].blank?
        @content_view_environments = []
      elsif params.key?(:content_view_environment_ids) && params[:content_view_environment_ids].blank?
        @content_view_environments = []
      end
    end

    def single_assignment?
      (params.key?(:environment_id) && params.key?(:content_view_id)) ||
      (params.key?(:environment) && params.key?(:content_view))
    end

    def update_cves?
      single_assignment? ||
        params.key?(:content_view_environments) || # multi
        params.key?(:content_view_environment_ids)
    end

    def find_host_collections
      ids = params[:activation_key][:host_collection_ids] if params[:activation_key]
      @host_collections = []

      ids&.each do |host_collection_id|
        host_collection = HostCollection.readable.find(host_collection_id)
        fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % host_collection_id if host_collection.nil?
        @host_collections << host_collection
      end
    end

    def verify_presence_of_organization_or_environment
      return if params.key?(:organization_id) || params.key?(:environment_id)
      fail HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
    end

    def permitted_params
      params.require(:activation_key).permit(:name,
                                             :description,
                                             :environment_id,
                                             :organization_id,
                                             :content_view_id,
                                             :release_version,
                                             :service_level,
                                             :auto_attach,
                                             :max_hosts,
                                             :unlimited_hosts,
                                             :purpose_role,
                                             :purpose_usage,
                                             :purpose_addon_ids,
                                             :content_overrides => [],
                                             :host_collection_ids => [],
                                             :content_view_environments => [],
                                             :content_view_environment_ids => []).to_h
    end

    def activation_key_params
      key_params = permitted_params.except(:environment_id, :content_view_id,
                      :content_view_environments, :content_view_environment_ids)

      unless params[:purpose_addons].nil?
        key_params[:purpose_addon_ids] = params[:purpose_addons].map { |addon| ::Katello::PurposeAddon.find_or_create_by(name: addon).id }
      end
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

    def verify_simple_content_access_disabled
      if @activation_key.organization.simple_content_access?
        fail HttpErrors::BadRequest, _("The specified organization is in Simple Content Access mode. Attaching subscriptions is disabled")
      end
    end

    def validate_release_version
      @organization ||= find_organization
      if params[:release_version].present? && !@organization.library.available_releases.include?(params[:release_version])
        fail HttpErrors::BadRequest, _("Invalid release version: [%s]") % params[:release_version]
      end
    end
  end
end
