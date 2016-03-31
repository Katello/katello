module Katello
  class Api::V2::HostSubscriptionsController < Katello::Api::V2::ApiController
    before_filter :find_host, :except => :create
    before_filter :check_subscriptions, :only => [:add_subscriptions, :remove_subscriptions]
    before_filter :find_content_view_environment, :only => :create

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/:host_id/subscriptions", N_("List a host's subscriptions")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def index
      @collection = index_response
      respond_for_index :collection => @collection
    end

    def index_response
      entitlements = @host.subscription_facet.candlepin_consumer.entitlements
      subscriptions = entitlements.map { |entitlement| ::Katello::HostSubscriptionPresenter.new(entitlement) }
      full_result_response(subscriptions)
    end

    api :PUT, "/hosts/:host_id/subscriptions/auto_attach", N_("Trigger an auto-attach of subscriptions")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def auto_attach
      sync_task(::Actions::Katello::Host::AutoAttachSubscriptions, @host)
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :GET, "/hosts/:host_id/subscriptions/events", N_("List subscription events for the host")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def events
      collection = full_result_response(@host.subscription_facet.candlepin_consumer.events.map { |e| OpenStruct.new(e) })
      respond_for_index :collection => collection
    end

    api :DELETE, "/hosts/:host_id/subscriptions/", N_("Unregister the host as a subscription consumer")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    def destroy
      sync_task(::Actions::Katello::Host::Unregister, @host)
      @host.reload
      respond_for_destroy(:resource => @host)
    end

    api :POST, "/hosts/subscriptions/", N_("Register a host with subscription and information.")
    param :name, String, :desc => N_("Name of the host"), :required => true
    param :uuid, String, :desc => N_("UUID to use for registered host, random uuid is generated if not provided")
    param :facts, Hash, :desc => N_("Key-value hash of subscription-manager facts, nesting uses a period delimiter (.)")
    param :hypervisor_guest_uuids, Array, :desc => N_("UUIDs of the virtual guests from the host's hypervisor")
    param :installed_products, Array, :desc => N_("List of products installed on the host") do
      param :product_id, String, :desc => N_("Product id as listed from a host's installed products, \
        this is not the same product id as the products api returns")
      param :product_name, String, :desc => N_("Product name as listed from a host's installed products")
    end
    param :release_version, String, :desc => N_("Release version of the content host")
    param :service_level, String, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT")
    param :lifecycle_environment_id, Integer, :desc => N_("Lifecycle Environment ID"), :required => true
    param :content_view_id, Integer, :desc => N_("Content View ID"), :required => true
    def create
      rhsm_params = params_to_rhsm_params
      name = rhsm_params[:facts]['network.hostname']

      host = Katello::Host::SubscriptionFacet.find_or_create_host(name, @content_view_environment.environment.organization, rhsm_params)
      sync_task(::Actions::Katello::Host::Register, host, System.new, rhsm_params, @content_view_environment)
      host.reload

      respond_for_show(:resource => host, :template => '../../../api/v2/hosts/show')
    end

    def params_to_rhsm_params
      rhsm_params = params.slice(:facts, :uuid, :name)
      rhsm_params[:releaseVer] = params['release_version'] if params['release_version']
      rhsm_params[:serviceLevel] = params['service_level'] if params['service_level']
      rhsm_params[:guestIds] = params['hypervisor_guest_uuids'] if params[:hypervisor_guest_uuids]
      rhsm_params[:type] = Katello::Candlepin::Consumer::SYSTEM
      rhsm_params[:facts] ||= {}
      rhsm_params[:facts]['network.hostname'] ||= rhsm_params[:name]

      if params['installed_products']
        rhsm_params[:installedProducts] = params['installed_products'].map do |product|
          { :productId => product['product_id'], :productName => product['product_name'] }
        end
      end
      rhsm_params
    end

    api :PUT, "/hosts/:host_id/subscriptions/remove_subscriptions"
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    param :subscriptions, Array, :desc => N_("Array of subscriptions to remove") do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, Integer, :desc => N_("If specified, remove the first instance of a subscription with matching id and quantity"), :required => false
    end
    def remove_subscriptions
      #combine the quantities for duplicate pools into PoolWithQuantities objects
      pool_id_quantities = params[:subscriptions].inject({}) do |new_hash, subscription|
        new_hash[subscription['id']] ||= PoolWithQuantities.new(Pool.find(subscription['id']))
        new_hash[subscription['id']].quantities << subscription['quantity']
        new_hash
      end

      @host.subscription_facet.remove_subscriptions(pool_id_quantities.values)
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :PUT, "/hosts/:host_id/subscriptions/add_subscriptions", N_("Add a subscription to a host")
    param :host_id, Integer, :desc => N_("Id of the host"), :required => true
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => true do
      param :id, String, :desc => N_("Subscription Pool id"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def add_subscriptions
      pools_with_quantities = params[:subscriptions].map do |sub_params|
        PoolWithQuantities.new(Pool.find(sub_params['id']), sub_params['quantity'])
      end

      sync_task(::Actions::Katello::Host::AttachSubscriptions, @host, pools_with_quantities)
      respond_for_index(:collection => index_response, :template => "index")
    end

    api :PUT, "/hosts/:host_id/subscriptions/content_override", N_("Set content overrides for the host")
    param :host_id, String, :desc => N_("Id of the content host"), :required => true
    param :content_label, String, :desc => N_("Label of the content"), :required => true
    param :value, [0, 1, String], :desc => N_("Override to 'yes', 'no', or 'default'"), :required => true
    def content_override
      content_override = validate_content_overrides(params)
      @host.subscription_facet.candlepin_consumer.set_content_override(content_override[:content_label], 'enabled', content_override[:value])

      product_content
    end

    api :GET, "/hosts/:host_id/subscriptions/product_content", N_("Get content and overrides for the host")
    param :host_id, String, :desc => N_("Id of the host"), :required => true
    def product_content
      content = @host.subscription_facet.candlepin_consumer.available_product_content
      overrides = @host.subscription_facet.candlepin_consumer.content_overrides
      results = content.map { |product_content| Katello::ProductContentPresenter.new(product_content, overrides) }

      respond_for_index(:collection => full_result_response(results))
    end

    private

    def validate_content_overrides(content_params)
      case content_params[:value].to_s.downcase
      when 'default'
        content_params[:value] = nil
      when '1', 'yes'
        content_params[:value] = 1
      when '0', 'no'
        content_params[:value] = 0
      else
        fail HttpErrors::BadRequest, _("Value must be 'yes', 'no', or 'default'")
      end

      available_content = @host.subscription_facet.candlepin_consumer.available_product_content
      unless available_content.map(&:content).any? { |content| content.label == content_params[:content_label] }
        fail HttpErrors::BadRequest, _("Invalid content label: %s") % content_params[:content_label]
      end
      content_params
    end

    def find_content_view_environment
      @content_view_environment = Katello::ContentViewEnvironment.where(:content_view_id => params[:content_view_id],
                                                                        :environment_id => params[:lifecycle_environment_id]).first
      fail HttpErrors::NotFound, _("Couldn't find specified Content View and Lifecycle Environment.") if @content_view_environment.nil?
    end

    def check_subscriptions
      fail HttpErrors::BadRequest, _("subscriptions not specified") if params[:subscriptions].nil? || params[:subscriptions].empty?
    end

    def find_host
      find_host_with_subscriptions(params[:host_id], "#{action_permission}_hosts")
    end

    def action_permission
      if ['add_subscriptions', 'remove_subscriptions', 'auto_attach', 'content_override'].include?(params[:action])
        :edit
      elsif ['index', 'events', 'product_content'].include?(params[:action])
        :view
      end
    end
  end
end
