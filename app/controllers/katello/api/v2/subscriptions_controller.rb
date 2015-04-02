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
  class Api::V2::SubscriptionsController < Api::V2::ApiController
    include ConsumersControllerLogic

    before_filter :find_activation_key
    before_filter :find_system
    before_filter :find_optional_organization, :only => [:index, :available, :show]
    before_filter :find_organization, :only => [:upload, :delete_manifest,
                                                :refresh_manifest, :manifest_history]
    before_filter :find_provider
    before_filter :find_subscription, :only => [:show]

    before_filter :load_search_service, :only => [:index, :available]

    skip_before_filter :check_content_type, :only => [:upload]

    resource_description do
      description "Subscriptions management."
      api_version 'v2'
    end

    api :GET, "/organizations/:organization_id/subscriptions", N_("List organization subscriptions")
    api :GET, "/systems/:system_id/subscriptions", N_("List a system's subscriptions"), :deprecated => true
    api :GET, "/activation_keys/:activation_key_id/subscriptions", N_("List an activation key's subscriptions")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    param :system_id, String, :desc => N_("UUID of the system"), :required => false
    param :activation_key_id, String, :desc => N_("Activation key ID"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      subscriptions = if @system
                        index_system
                      elsif @activation_key
                        index_activation_key
                      else
                        index_organization
                      end

      respond_for_index(:collection => subscriptions)
    end

    api :GET, "/organizations/:organization_id/subscriptions/:id", N_("Show a subscription")
    api :GET, "/subscriptions/:id", N_("Show a subscription")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :id, :number, :desc => N_("Subscription identifier"), :required => true
    def show
      respond :resource => @subscription
    end

    def available
      subscriptions = if @system
                        available_system
                      elsif @activation_key
                        available_activation_key
                      else
                        available_organization
                      end

      respond_for_index(:collection => subscriptions, :template => 'index')
    end

    api :POST, "/subscriptions/:id", N_("Add a subscription to a resource")
    api :POST, "/systems/:system_id/subscriptions", N_("Add a subscription to a system"), :deprecated => true
    api :POST, "/activation_keys/:activation_key_id/subscriptions", N_("Add a subscription to an activation key")
    param :id, String, :desc => N_("Subscription Pool uuid"), :required => false
    param :system_id, String, :desc => N_("UUID of the system"), :required => false
    param :activation_key_id, String, :desc => N_("ID of the activation key"), :required => false
    param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => false
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid"), :required => true
      param :quantity, :number, :desc => N_("Quantity of this subscriptions to add"), :required => true
    end
    def create
      object = @system || @activation_key || @distributor

      if params[:subscriptions]
        params[:subscriptions].each do |subscription|
          object.subscribe(subscription[:id], subscription[:quantity])
        end
      elsif params[:id] && params.key?(:quantity)
        object.subscribe(params[:id], params[:quantity])
      end

      subscriptions = if @system
                        index_system
                      elsif @activation_key
                        index_activation_key
                      else
                        index_organization
                      end

      respond_for_index(:collection => subscriptions, :template => 'index')
    end

    api :DELETE, "/subscriptions/:id", N_("Unattach a subscription")
    api :DELETE, "/systems/:system_id/subscriptions/:id", N_("Unattach a subscription"), :deprecated => true
    api :DELETE, "/activation_keys/:activation_key_id/subscriptions/:id", N_("Unattach a subscription")
    param :id, String, :desc => N_("Subscription ID"), :required => false
    param :system_id, String, :desc => N_("UUID of the system")
    param :activation_key_id, String, :desc => N_("activation key ID")
    param :subscriptions, Array, :desc => N_("Array of subscriptions to add"), :required => false do
      param :id, String, :desc => N_("Subscription Pool uuid")
    end
    def destroy
      object = @system || @activation_key || @distributor

      if params[:subscriptions].present?
        params[:subscriptions].each do |subscription|
          object.unsubscribe(subscription[:id])
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
                      else
                        index_organization
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

    def find_subscription
      @subscription = Pool.find_by_id!(params[:id])
    end

    private

    def index_system
      subs = @system.consumed_entitlements
      # TODO: pluck id and call elasticsearch?
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
      # TODO: pluck id and call elasticsearch?
      subscriptions = {
        :results => subs,
        :subtotal => subs.count,
        :total => subs.count,
        :page => 1,
        :per_page => subs.count
      }

      return subscriptions
    end

    def index_organization
      filters = []
      filters << {:term => {:org => [@organization.label]}}

      options = {
        :filters => filters,
        :load_records? => false,
        :default_field => :product_name
      }

      subscriptions = item_search(Pool, params, options)

      return subscriptions
    end

    api :GET, "/systems/:system_id/subscriptions/available", N_("List available subscriptions"), :deprecated => true
    param :system_id, String, :desc => N_("UUID of the system"), :required => true
    param :match_system, :bool, :desc => N_("Return subscriptions that match system")
    param :match_installed, :bool, :desc => N_("Return subscriptions that match installed")
    param :no_overlap, :bool, :desc => N_("Return subscriptions that don't overlap")
    def available_system
      params[:match_system] = params[:match_system].to_bool if params[:match_system]
      params[:match_installed] = params[:match_installed].to_bool if params[:match_installed]
      params[:no_overlap] = params[:no_overlap].to_bool if params[:no_overlap]
      pools = @system.filtered_pools(params[:match_system], params[:match_installed],
                                     params[:no_overlap])
      available = available_subscriptions(pools, @system.organization)

      subscriptions = {
        :results => available,
        :subtotal => available.count,
        :total => available.count
      }

      return subscriptions
    end

    def available_activation_key
      @organization = @activation_key.organization
      subs = @activation_key.available_subscriptions
      subscriptions = {
        :results => subs,
        :subtotal => subs.count,
        :total => subs.count,
        :page => 1,
        :per_page => subs.count
      }

      return subscriptions
    end

    def available_organization
      # TODO: perhaps /organizations/:organization_id/available to return just subs w/ unused quantity?
      # TODO: or just those w/ repos enabled?  (eg. sub-mgr list --available)

      filters = []
      filters << {:terms => {:cp_id => subscriptions.collect(&:cp_id)}}
      filters << {:term => {:org => [@organization.label]}}
      filters << {:term => {:provider_id => [@organization.redhat_provider.id]}}
      options = {
        :filters => filters,
        :load_records? => false,
        :default_field => :product_name
      }

      subscriptions = item_search(Pool, params, options)

      return subscriptions
    end
  end
end
