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
  class Api::V2::ActivationKeysController < Api::V2::ApiController
    before_filter :verify_presence_of_organization_or_environment, :only => [:index]
    before_filter :find_environment, :only => [:index, :create, :update]
    before_filter :find_optional_organization, :only => [:index, :create, :show]
    before_filter :find_activation_key, :only => [:update, :destroy, :available_releases, :copy, :product_content,
                                                  :available_host_collections, :add_host_collections, :remove_host_collections,
                                                  :content_override, :add_subscriptions, :remove_subscriptions]
    before_filter :authorize
    before_filter :load_search_service, :only => [:show, :index, :available_host_collections]
    before_filter :search_for_activation_key, :only => [:show]

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
      respond_for_index(:collection => search_for_activation_keys)
    end

    api :POST, "/activation_keys", N_("Create an activation key")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => true
    param :name, String, :desc => N_("name"), :required => true
    param :description, String, :desc => N_("description")
    param :environment, Hash, :desc => N_("environment")
    param :environment_id, :identifier, :desc => N_("environment id")
    param :content_view_id, :identifier, :desc => N_("content view id")
    param :max_content_hosts, :number, :desc => N_("maximum number of registered content hosts")
    param :unlimited_content_hosts, :bool, :desc => N_("can the activation key have unlimited content hosts")
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
    param :max_content_hosts, :number, :desc => N_("maximum number of registered content hosts")
    param :unlimited_content_hosts, :bool, :desc => N_("can the activation key have unlimited content hosts")
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
      @new_activation_key = @activation_key.copy(params[:new_name])
      @new_activation_key.user = current_user
      sync_task(::Actions::Katello::ActivationKey::Create, @new_activation_key)
      @new_activation_key.reload
      @new_activation_key.update_attributes!(
                                             :service_level => @activation_key.service_level,
                                             :release_version => @activation_key.release_version
                                            )
      @activation_key.content_overrides.each do |content|
        @new_activation_key.set_content_override(content['contentLabel'], content[:name], content[:value])
      end
      @activation_key.get_key_pools.each do |pool|
        @new_activation_key.subscribe(pool[:id], pool[:amount])
      end
      respond_for_show(:resource => @new_activation_key)
    end

    api :GET, "/activation_keys/:id/host_collections/available", N_("List host collections the system does not belong to")
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => N_("host collection name to filter by")
    def available_host_collections
      filters = [:terms => { :id => HostCollection.readable.pluck("#{Katello::HostCollection.table_name}.id") -
                   @activation_key.host_collections.pluck("#{Katello::HostCollection.table_name}.id") }]
      filters << { :term => { :name => params[:name] } } if params[:name]
      filters << { :term => { :organization_id => @activation_key.organization_id } }

      options = {
        :filters       => filters,
        :load_records? => true
      }

      respond_for_index(:collection => item_search(HostCollection, params, options))
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
    def product_content
      content = @activation_key.available_content
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
    param :label, String, :desc => N_("Label of the content"), :required => false
    param :value, :number, :desc => N_("Override value 0/1"), :required => false
    def content_override
      if params[:label]
        params[:content_override] = {}
        params[:content_override][:content_label] = params[:label]
        params[:content_override][:name] = "enabled"
        params[:content_override][:value] = params[:value]
      end
      content_override = params[:content_override]
      @activation_key.set_content_override(content_override[:content_label],
                                           content_override[:name], content_override[:value]) if content_override
      respond_for_show(:resource => @activation_key)
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

    def find_activation_key
      @activation_key = ActivationKey.find(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % params[:id] if @activation_key.nil?
      @activation_key
    end

    def search_for_activation_key
      search_result = search_for_activation_keys
      fail HttpErrors::NotFound, _("Couldn't find activation key") % params[:id] if search_result[:results].empty?
      fail HttpErrors::NotFound, _("found more than one activation key") % params[:id] if search_result[:results].size > 1
      @activation_key = search_result[:results].first
      @activation_key
    end

    def find_pool
      @pool = Pool.find_by_organization_and_id(@activation_key.organization, params[:poolid])
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

    def search_for_activation_keys
      ids = ActivationKey.readable.pluck(:id)
      ids &= [params[:id].to_i] if params[:id]
      filters = [:terms => { :id => ids }]
      filters << { :term => {:organization_id => @organization.id} } if params[:organization_id]
      filters << { :terms => {:environment_id => [params[:environment_id]] } } if params[:environment_id]
      filters << { :terms => {:content_view_id => [params[:content_view_id]] } } if params[:content_view_id]
      filters << { :term => { :name => params[:name] } } if params[:name]

      options = {
        :filters       => filters,
        :load_records? => true
      }
      item_search(ActivationKey, params, options)
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
                                                          :max_content_hosts,
                                                          :unlimited_content_hosts,
                                                          :content_overrides => [],
                                                          :host_collection_ids => [])

      key_params[:environment_id] = params[:environment][:id] if params[:environment].try(:[], :id)
      key_params[:content_view_id] = params[:content_view][:id] if params[:content_view].try(:[], :id)
      unlimited = params[:activation_key].try(:[], :unlimited_content_hosts)
      max_hosts = params[:activation_key].try(:[], :max_content_hosts)

      if unlimited && max_hosts
        key_params[:unlimited_content_hosts] = true
        key_params[:max_content_hosts] = nil
      else
        key_params[:unlimited_content_hosts] = false if max_hosts
        key_params[:max_content_hosts] = nil if unlimited
      end

      key_params
    end
  end
end
