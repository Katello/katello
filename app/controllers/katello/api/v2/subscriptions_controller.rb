module Katello
  class Api::V2::SubscriptionsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_filter :find_activation_key
    before_filter :find_system
    before_filter :find_optional_organization, :only => [:index, :available, :show]
    before_filter :find_organization, :only => [:upload, :delete_manifest,
                                                :refresh_manifest, :manifest_history]
    before_filter :find_provider

    skip_before_filter :check_content_type, :only => [:upload]

    resource_description do
      description "Subscriptions management."
      api_version 'v2'
    end

    api :GET, "/organizations/:organization_id/subscriptions", N_("List organization subscriptions")
    api :GET, "/systems/:system_id/subscriptions", N_("List a content host's subscriptions"), :deprecated => true
    api :GET, "/activation_keys/:activation_key_id/subscriptions", N_("List an activation key's subscriptions")
    api :GET, "/subscriptions"
    param_group :search, Api::V2::ApiController
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    param :system_id, String, :desc => N_("UUID of a content host"), :required => false
    param :activation_key_id, String, :desc => N_("Activation key ID"), :required => false
    param :available_for, String, :desc => N_("Object to show subscriptions available for, either 'content_host' or 'activation_key'"), :required => false
    param :match_system, :bool, :desc => N_("Return subscriptions that match content_host")
    param :match_installed, :bool, :desc => N_("Return subscriptions that match installed products")
    param :no_overlap, :bool, :desc => N_("Return subscriptions which do not overlap with a currently-attached subscription")
    def index
      respond(:collection => scoped_search(index_relation.uniq, :cp_id, :asc, :resource_class => Pool))
    end

    def index_relation
      return available_for_system if params[:available_for] == "content_host"
      return available_for_activation_key if params[:available_for] == "activation_key"
      collection = Pool.readable
      collection = collection.where(:id => ActivationKey.find(params[:activation_key_id]).pools) if params[:activation_key_id]
      collection = collection.get_for_organization(Organization.find(params[:organization_id])) if params[:organization_id]
      if params[:system_id]
        pool_ids = System.find_by_uuid(params[:system_id]).pools.map { |x| x['id'] }
        collection = collection.where(:cp_id => pool_ids)
      end
      collection
    end

    api :GET, "/organizations/:organization_id/subscriptions/:id", N_("Show a subscription")
    api :GET, "/subscriptions/:id", N_("Show a subscription")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :id, :number, :desc => N_("Subscription identifier"), :required => true
    def show
      @resource = Katello::Pool.with_identifier(params[:id])
      respond(@resource)
    end

    def available
      subscriptions = if @system
                        available_for_system
                      elsif @activation_key
                        available_for_activation_key
                      else
                        Organization.find(params[:organization_id]).subscriptions if params[:organization_id]
                      end

      respond_for_index(:collection => scoped_search(subscriptions.uniq, :cp_id, :asc, :resource_class => Pool), :template => "index")
    end

    api :POST, "/systems/:system_id/subscriptions", N_("Add a subscription to a content host"), :deprecated => true
    api :POST, "/activation_keys/:activation_key_id/subscriptions", N_("Add a subscription to an activation key")
    param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
    param :system_id, String, :desc => N_("UUID of a content host"), :required => false
    param :activation_key_id, String, :desc => N_("ID of the activation key"), :required => false
    param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def create
      object = @system || @activation_key

      if params[:subscriptions]
        params[:subscriptions].each do |sub|
          subscription = Pool.find(sub[:id])
          object.subscribe(subscription.cp_id, subscription[:quantity])
        end
      elsif params[:id] && params.key?(:quantity)
        sub = subscription.find(params[:id])
        object.subscribe(sub.cp_id, params[:quantity])
      end

      subscriptions = if @system
                        index_system
                      elsif @activation_key
                        index_activation_key
                      end

      respond_for_index(:collection => subscriptions, :template => 'index')
    end

    api :DELETE, "/systems/:system_id/subscriptions/:id", N_("Unattach a subscription"), :deprecated => true
    api :DELETE, "/activation_keys/:activation_key_id/subscriptions/:id", N_("Unattach a subscription")
    param :id, String, :desc => N_("Subscription ID"), :required => false
    param :system_id, String, :desc => N_("UUID of a content host")
    param :activation_key_id, String, :desc => N_("activation key ID")
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid")
    end
    def destroy
      object = @system || @activation_key

      if @system
        params[:subscriptions].each do |subscription|
          entitlement_id = @system.find_entitlement(subscription[:id])
          object.unsubscribe(entitlement_id)
        end
      elsif params[:id]
        object.unsubscribe(params[:id])
      else
        @system.unsubscribe_all
      end

      subscriptions = if @system
                        index_system
                      elsif @activation_key
                        index_activation_key
                      end

      respond_for_index(:collection => subscriptions, :template => 'index')
    end

    api :POST, "/organizations/:organization_id/subscriptions/upload", N_("Upload a subscription manifest")
    api :POST, "/subscriptions/upload", N_("Upload a subscription manifest")
    param :organization_id, :number, :desc => N_("Organization id"), :required => true
    param :content, File, :desc => N_("Subscription manifest file"), :required => true
    param :repository_url, String, :desc => N_("repository url"), :required => false
    def upload
      fail HttpErrors::BadRequest, _("No manifest file uploaded") if params[:content].blank?

      begin
        # candlepin requires that the file has a zip file extension
        temp_file = File.new(File.join("#{Rails.root}/tmp", "import_#{SecureRandom.hex(10)}.zip"), 'wb+', 0600)
        temp_file.write params[:content].read
      ensure
        temp_file.close
      end

      # repository url
      if repo_url = params[:repository_url]
        @provider.repository_url = repo_url
        @provider.save!
      end

      task = async_task(::Actions::Katello::Provider::ManifestImport, @provider, File.expand_path(temp_file.path), params[:force])
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:organization_id/subscriptions/refresh_manifest", N_("Refresh previously imported manifest for Red Hat provider")
    param :organization_id, :number, :desc => N_("Organization id"), :required => true
    def refresh_manifest
      details  = @provider.organization.owner_details
      upstream = details['upstreamConsumer'].blank? ? {} : details['upstreamConsumer']

      task = async_task(::Actions::Katello::Provider::ManifestRefresh, @provider, upstream)
      respond_for_async :resource => task
    end

    api :POST, "/organizations/:organization_id/subscriptions/delete_manifest", N_("Delete manifest from Red Hat provider")
    param :organization_id, :number, :desc => N_("Organization id"), :required => true
    def delete_manifest
      task = async_task(::Actions::Katello::Provider::ManifestDelete, @provider)
      respond_for_async :resource => task
    end

    api :GET, "/organizations/:organization_id/subscriptions/manifest_history", N_("obtain manifest history for subscriptions")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    def manifest_history
      @manifest_history = @organization.manifest_history
      respond_with_template_collection(params[:action], "subscriptions", collection: @manifest_history)
    end

    api :GET, "/systems/:system_id/subscriptions/available", N_("List available subscriptions"), :deprecated => true
    param :system_id, String, :desc => N_("UUID of a content host"), :required => true
    param :match_system, :bool, :desc => N_("Return subscriptions that match a content host")
    param :match_installed, :bool, :desc => N_("Return subscriptions that match installed products")
    param :no_overlap, :bool, :desc => N_("Return subscriptions which do not overlap with a currently-attached subscription")
    def available_for_system
      params[:match_system] = ::Foreman::Cast.to_bool(params[:match_system]) if params[:match_system]
      params[:match_installed] = ::Foreman::Cast.to_bool(params[:match_installed]) if params[:match_installed]
      params[:no_overlap] = ::Foreman::Cast.to_bool(params[:no_overlap]) if params[:no_overlap]
      pools = @system.filtered_pools(params[:match_system], params[:match_installed],
                                     params[:no_overlap])
      if pools
        available = pools.collect { |cp_pool| ::Katello::Pool.find_by_cp_id(cp_pool['id']) }
        available.compact!
        available.select { |pool| pool.provider?(Organization.find(params[:organization_id])) }
      end

      available || []
    end

    protected

    def find_system
      @system = System.find_by_uuid!(params[:system_id]) if params[:system_id]
    end

    def find_activation_key
      @activation_key = ActivationKey.find_by_id!(params[:activation_key_id]) if params[:activation_key_id]
    end

    def find_provider
      @organization = @system.organization if @system
      @organization = @activation_key.organization if @activation_key
      @organization = @subscription.organization if @subscription
      @provider = @organization.redhat_provider if @organization
    end

    private

    def resource_class
      Pool
    end

    def default_sort
      %w(id desc)
    end

    def index_system
      subs = @system.entitlements

      subscriptions = {
        :results => subs,
        :subtotal => subs.count,
        :total => subs.count,
        :page => 1,
        :per_page => subs.count
      }

      return subscriptions
    end

    def index_activation_key
      @organization = @activation_key.organization
      subs = @activation_key.subscriptions

      subscriptions = {
        :results => subs,
        :subtotal => subs.count,
        :total => subs.count,
        :page => 1,
        :per_page => subs.count
      }

      return subscriptions
    end

    def available_for_activation_key
      @activation_key.available_subscriptions
    end
  end
end
