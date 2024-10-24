module Katello
  class Api::V2::HostSubscriptionsController < Katello::Api::V2::ApiController
    include Katello::Concerns::Api::V2::ContentOverridesController
    before_action :find_host, :except => :create
    before_action :check_subscriptions, :only => [:add_subscriptions, :remove_subscriptions]
    before_action :find_content_view_environment, :only => :create
    before_action :check_registration_services, :only => [:destroy, :create]
    before_action :find_content_overrides, :only => [:content_override]

    def_param_group :installed_products do
      param :product_id, String, :desc => N_("Product id as listed from a host's installed products, \
        this is not the same product id as the products api returns")
      param :product_name, String, :desc => N_("Product name as listed from a host's installed products")
      param :arch, String, :desc => N_("Product architecture")
      param :version, String, :desc => N_("Product version")
    end

    def_param_group :subscription_facet_attributes do
      param :release_version, String, :desc => N_("Release version for this Host to use (7Server, 7.1, etc)")
      param :autoheal, :bool, :desc => N_("Sets whether the Host will autoheal subscriptions upon checkin")
      param :purpose_usage, String, :desc => N_("Sets the system purpose usage")
      param :purpose_role, String, :desc => N_("Sets the system purpose usage")
      param :purpose_addons, Array, :desc => N_("Sets the system add-ons")
      param :service_level, String, :desc => N_("Service level to be used for autoheal")
      param :hypervisor_guest_uuids, Array, :desc => N_("List of hypervisor guest uuids")
      param :installed_products_attributes, Array, :desc => N_("List of products installed on the host") do
        param_group :installed_products, Api::V2::HostSubscriptionsController
      end
    end

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def deprecate_entitlement_mode_endpoint
      ::Foreman::Deprecation.api_deprecation_warning(N_("This endpoint is deprecated and will be removed in an upcoming release. Simple Content Access is the only supported content access mode."))
    end

    api :GET, "/hosts/:host_id/subscriptions", N_("List a host's subscriptions"), deprecated: true
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def index
      deprecate_entitlement_mode_endpoint
      @collection = index_response
      respond_for_index :collection => @collection
    end

    def index_response(reload_host: false)
      # Host needs to be reloaded because of lazy accessor
      @host.reload if reload_host
      presenter = ::Katello::HostSubscriptionsPresenter.new(@host)
      full_result_response(presenter.subscriptions)
    end

    api :PUT, "/hosts/:host_id/subscriptions/auto_attach", N_("Trigger an auto-attach of subscriptions"), deprecated: true
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def auto_attach
      deprecate_entitlement_mode_endpoint
      if @host.organization.simple_content_access?
        fail ::Katello::HttpErrors::BadRequest, _("This host's organization is in Simple Content Access mode. Auto-attach is disabled")
      end

      sync_task(::Actions::Katello::Host::AutoAttachSubscriptions, @host)
      respond_for_index(:collection => index_response(reload_host: true), :template => "index")
    end

    api :DELETE, "/hosts/:host_id/subscriptions/", N_("Unregister the host as a subscription consumer")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def destroy
      Katello::RegistrationManager.unregister_host(@host, :unregistering => true)
      @host.reload
      respond_for_destroy(:resource => @host)
    end

    api :POST, "/hosts/subscriptions/", N_("Register a host with subscription and information")
    param :name, String, :desc => N_("Name of the host"), :required => true
    param :uuid, String, :desc => N_("UUID to use for registered host, random uuid is generated if not provided")
    param :facts, Hash, :desc => N_("Key-value hash of subscription-manager facts, nesting uses a period delimiter (.)")
    param :hypervisor_guest_uuids, Array, :desc => N_("UUIDs of the virtual guests from the host's hypervisor")
    param :installed_products, Array, :desc => N_("List of products installed on the host") do
      param_group :installed_products, ::Katello::Api::V2::HostSubscriptionsController
    end
    param :release_version, String, :desc => N_("Release version of the content host")
    param :service_level, String, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT")
    param :lifecycle_environment_id, Integer, :desc => N_("Lifecycle Environment ID"), :required => true
    param :content_view_id, Integer, :desc => N_("Content View ID"), :required => true
    def create
      rhsm_params = params_to_rhsm_params

      host = Katello::RegistrationManager.process_registration(rhsm_params, [@content_view_environment])
      host.reload
      ::Katello::Host::SubscriptionFacet.update_facts(host, rhsm_params[:facts]) unless rhsm_params[:facts].blank?

      respond_for_show(:resource => host, :full_template => 'katello/api/v2/hosts/show')
    end

    def params_to_rhsm_params
      rhsm_params = params.slice(:facts, :uuid, :name).to_unsafe_h
      rhsm_params[:releaseVer] = params['release_version'] if params['release_version']
      rhsm_params[:usage] = params['purpose_usage'] if params['purpose_usage']
      rhsm_params[:role] = params['purpose_role'] if params['purpose_role']
      rhsm_params[:addOns] = params['purpose_addons'] if params['purpose_addons']
      rhsm_params[:serviceLevel] = params['service_level'] if params['service_level']
      rhsm_params[:guestIds] = params['hypervisor_guest_uuids'] if params[:hypervisor_guest_uuids]
      rhsm_params[:type] = Katello::Candlepin::Consumer::SYSTEM
      rhsm_params[:facts] ||= {}
      rhsm_params[:facts]['network.hostname'] ||= rhsm_params[:name]

      if params['installed_products'] #convert api installed_product to candlepin params
        rhsm_params[:installedProducts] = params['installed_products'].map do |product|
          product_params = { :productId => product['product_id'], :productName => product['product_name'] }
          product_params[:arch] = product['arch'] if product['arch']
          product_params[:version] = product['version'] if product['version']
          product_params
        end
      end
      rhsm_params
    end

    api :PUT, "/hosts/:host_id/subscriptions/remove_subscriptions", N_("Remove subscriptions from a host"), deprecated: true
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    param :subscriptions, Array, :desc => N_("Array of subscriptions to remove") do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, Integer, :desc => N_("If specified, remove the first instance of a subscription with matching id and quantity"), :required => false
    end
    def remove_subscriptions
      deprecate_entitlement_mode_endpoint
      #combine the quantities for duplicate pools into PoolWithQuantities objects
      pool_id_quantities = params.require(:subscriptions).inject({}) do |new_hash, subscription|
        new_hash[subscription['id']] ||= PoolWithQuantities.new(Pool.with_identifier(subscription['id']))
        new_hash[subscription['id']].quantities << subscription['quantity']
        new_hash
      end

      sync_task(::Actions::Katello::Host::RemoveSubscriptions, @host, pool_id_quantities.values)
      respond_for_index(:collection => index_response(reload_host: true), :template => "index")
    end

    api :PUT, "/hosts/:host_id/subscriptions/add_subscriptions", N_("Add a subscription to a host"), deprecated: true
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => true do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def add_subscriptions
      deprecate_entitlement_mode_endpoint
      if @host.organization.simple_content_access?
        fail ::Katello::HttpErrors::BadRequest, _("This host's organization is in Simple Content Access mode. Attaching subscriptions is disabled.")
      end

      pools_with_quantities = params.require(:subscriptions).map do |sub_params|
        PoolWithQuantities.new(Pool.with_identifier(sub_params['id']), sub_params['quantity'].to_i)
      end

      sync_task(::Actions::Katello::Host::AttachSubscriptions, @host, pools_with_quantities)
      respond_for_index(:collection => index_response(reload_host: true), :template => "index")
    end

    api :GET, "/hosts/:host_id/subscriptions/product_content", N_("Get content and overrides for the host")
    param :host_id, String, :desc => N_("Id of the host"), :required => true
    param :content_access_mode_all, :bool, :desc => N_("Get all content available, not just that provided by subscriptions")
    param :content_access_mode_env, :bool, :desc => N_("Limit content to just that available in the host's content view version")
    param_group :search, Api::V2::ApiController
    def product_content
      # NOTE: this is just there as a placeholder for apipie.
      # The routing would automatically redirect it to repository_sets#index
    end

    api :PUT, "/hosts/:host_id/subscriptions/content_override", N_("Set content overrides for the host")
    param :host_id, String, :desc => N_("Id of the content host"), :required => true
    param :value, String, :desc => N_("Override to a boolean value or 'default'"), :required => false
    param :content_overrides, Array, :desc => N_("Array of Content override parameters") do
      param :content_label, String, :desc => N_("Label of the content"), :required => true
      param :value, String, :desc => N_("Override value. Provide a boolean value if name is 'enabled'"), :required => false
      param :name, String, :desc => N_("Override key or name. Note if name is not provided the default name will be 'enabled'"), :required => false
      param :remove, :bool, :desc => N_("Set true to remove an override and reset it to 'default'"), :required => false
    end
    param :content_overrides_search, Hash, :desc => N_("Content override search parameters") do
      param_group :search, Api::V2::ApiController
      param :enabled, :bool, :desc => N_("Set true to override to enabled; Set false to override to disabled.'"), :required => false
      param :limit_to_env, :bool, :desc => N_("Limit actions to content in the host's environment."), :required => false
      param :remove, :bool, :desc => N_("Set true to remove an override and reset it to 'default'"), :required => false
    end
    def content_override
      content_override_values = @content_overrides.map do |override_params|
        validate_content_overrides_enabled(override_params)
      end
      sync_task(::Actions::Katello::Host::UpdateContentOverrides, @host, content_override_values, false)
      fetch_product_content
    end

    api :GET, "/hosts/:host_id/subscriptions/available_release_versions", N_("Show releases available for the content host")
    param :host_id, String, :desc => N_("id of host"), :required => true
    def available_release_versions
      releases = @host.content_facet.try(:available_releases) || []
      respond_for_index :collection => full_result_response(releases)
    end

    api :GET, "/hosts/:host_id/subscriptions/enabled_repositories", N_("Show repositories enabled on the host that are known to Katello")
    param :host_id, String, :desc => N_("id of host"), :required => true
    def enabled_repositories
      repositories = @host.content_facet.try(:bound_repositories) || []
      respond_with_template_collection "index", 'repositories', :collection => full_result_response(repositories)
    end

    private

    def fetch_product_content
      content_finder = ProductContentFinder.new(:consumable => @host.subscription_facet)
      content = content_finder.presenter_with_overrides(@host.subscription_facet.candlepin_consumer.content_overrides)
      respond_with_template_collection("index", 'repository_sets', :collection => full_result_response(content))
    end

    def find_content_view_environment
      @content_view_environment = Katello::ContentViewEnvironment.where(:content_view_id => params[:content_view_id],
                                                                        :environment_id => params[:lifecycle_environment_id]).first
      fail HttpErrors::NotFound, _("Couldn't find specified content view and lifecycle environment.") if @content_view_environment.nil?
    end

    def check_subscriptions
      fail HttpErrors::BadRequest, _("subscriptions not specified") if params[:subscriptions].blank?
    end

    def check_registration_services
      fail "Unable to register system, not all services available" unless Katello::RegistrationManager.check_registration_services
    end

    def find_host
      find_host_with_subscriptions(params[:host_id], "#{action_permission}_hosts")
    end

    def action_permission
      if ['add_subscriptions', 'destroy', 'remove_subscriptions', 'auto_attach', 'content_override'].include?(params[:action])
        :edit
      elsif ['index', 'events', 'product_content', 'available_release_versions', 'enabled_repositories'].include?(params[:action])
        :view
      else
        fail ::Foreman::Exception.new(N_("unknown permission for %s"), "#{params[:controller]}##{params[:action]}")
      end
    end

    def find_content_overrides
      if !params.dig(:content_overrides_search, :search).nil?

        content_labels = ::Katello::Content.joins(:product_contents)
                            .where("#{Katello::ProductContent.table_name}.product_id": @host.organization.products.subscribable.enabled)
                            .search_for(params[:content_overrides_search][:search])
                            .pluck(:label)

        if Foreman::Cast.to_bool(params.dig(:content_overrides_search, :limit_to_env))
          env_content = ProductContentFinder.new(
              :match_subscription => false,
              :match_environment => true,
              :consumable => @host.subscription_facet
          ).product_content
          env_content_labels = ::Katello::Content.find(env_content.pluck(:content_id)).pluck(:label)
          content_labels &= env_content_labels
        end

        @content_overrides = content_labels.map do |label|
          { content_label: label,
            value: Foreman::Cast.to_bool(params[:content_overrides_search][:enabled]),
            remove: Foreman::Cast.to_bool(params[:content_overrides_search][:remove])
          }
        end
      else
        @content_overrides = params[:content_overrides] || []
      end
    end
  end
end
