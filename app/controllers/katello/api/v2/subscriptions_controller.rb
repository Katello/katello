#
# Copyright 2013 Red Hat, Inc.
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

  before_filter :find_system, :except => [:create]
  before_filter :find_system_or_distributor, :only => [:create]
  before_filter :find_optional_organization, :only => [:index]
  before_filter :find_organization, :only => [:show, :upload]
  before_filter :find_subscription, :only => [:show]
  before_filter :find_provider
  before_filter :authorize

  resource_description do
    description "Systems subscriptions management."
    api_version 'v2'
  end

  def rules
    read_test = lambda { @system ? @system.readable? : @provider.readable? }
    available_test = lambda { Organization.any_readable? }
    system_modification_test = lambda { @system.editable? }
    edit_test = lambda { @provider.editable? }

    {
      :index => read_test,
      :show => read_test,
      :create => system_modification_test,
      :destroy => system_modification_test,
      :destroy_all => system_modification_test,
      :available => available_test,
      :upload => edit_test
    }
  end

  api :GET, "/systems/:system_id/subscriptions", "List system subscriptions"
  api :GET, "/organizations/:organization_id/subscriptions", "List organization subscriptions"
  param :system_id, String, :desc => "UUID of the system", :required => false
  param :organization_id, :identifier, :desc => "Organization id", :required => false
  # rubocop:disable SymbolName
  def index
    if @system
      subs = @system.consumed_entitlements
      subscriptions = {
          :subscriptions => subs,
          :subtotal => subs.count,
          :total => subs.count
      }
    else
      filters = []

      # Limit subscriptions to current org and Red Hat provider
      filters << {:term => {:org => [@organization.label]}}
      filters << {:term => {:provider_id => [@organization.redhat_provider.id]}}

      options = {
          :filters => filters,
          :load_records? => false,
          :default_field => :productName
      }

      # Without any search terms, reindex all subscriptions in elasticsearch. This is to ensure
      # that the latest information is searchable.
      if params[:offset].to_i == 0 && params[:search].blank?
        @organization.redhat_provider.index_subscriptions
      end

      subscriptions = item_search(Pool, params, options)
    end

    respond(:collection => subscriptions)
  end

  api :GET, "/organizations/:organization_id/subscriptions/:id", "Show a subscription"
  param :organization_id, :number, :desc => "Organization identifier", :required => true
  param :id, :number, :desc => "Subscription identifier", :required => true
  def show
    respond :resource => @subscription
  end

  api :GET, "/systems/:system_id/subscriptions/available", "List available subscriptions"
  param :system_id, String, :desc => "UUID of the system", :required => true
  param :match_system, :bool, :desc => "Return subscriptions that match system"
  param :match_installed, :bool, :desc => "Return subscriptions that match installed"
  param :no_overlap, :bool, :desc => "Return subscriptions that don't overlap"
  def available
    params[:match_system] = params[:match_system].to_bool if params[:match_system]
    params[:match_installed] = params[:match_installed].to_bool if params[:match_installed]
    params[:no_overlap] = params[:no_overlap].to_bool if params[:no_overlap]

    pools = @system.filtered_pools(params[:match_system], params[:match_installed],
      params[:no_overlap])
    available = available_subscriptions(pools, @system.organization)

    collection = {
        :results => available,
        :subtotal => available.count,
        :total => available.count
    }

    respond_for_index(:collection => collection, :template => :index)
  end

  api :POST, "/subscriptions/:subscription_id",
      "Attach a subscription to a system or distributor"
  api :POST, "/systems/:system_id/subscriptions",
      "Attach a subscription to a system"
  api :POST, "/distributors/:distributor_id/subscriptions",
      "Attach a subscription to a subscription manager application"
  param :system_id, String, :desc => "UUID of the system"
  param :distributor_id, String, :desc => "UUID of the subscription manager application"
  param :subscription_id, String, :desc => "Subscription UUID", :required => true
  param :quantity, :number, :desc => "Number of subscriptions to attach (defaults to suggested quantity)"
  def create
    @system.subscribe(subscriptions_params)
    respond :resource => @system
  end

  api :DELETE, "/systems/:system_id/subscriptions/:id", "Delete a subscription"
  param :id, :number, :desc => "Entitlement id"
  param :system_id, String, :desc => "UUID of the system", :required => true
  def destroy
    expected_params = params.slice(:id)
    fail HttpErrors::BadRequest, _("Please provide subscription ID") if expected_params.count != 1
    @system.unsubscribe(expected_params[:id])
    respond_for_show :resource => @system
  end

  api :DELETE, "/systems/:system_id/subscriptions", "Delete all system subscriptions"
  param :system_id, String, :desc => "UUID of the system", :required => true
  def destroy_all
    @system.unsubscribe_all
    respond_for_show :resource => @system
  end

  api :POST, "/organizations/:organization_id/subscriptions/upload", "Upload a subscription manifest"
  api :POST, "/subscriptions/upload", "Upload a subscription manifest"
  param :organization_id, :identifier, :desc => "Organization id", :required => true
  param :content, File, :desc => "Subscription manifest file", :required => true
  def upload
    fail HttpErrors::BadRequest, _("No manifest file uploaded") if params[:content].blank?

    begin
      # candlepin requires that the file has a zip file extension
      temp_file = File.new(File.join("#{Rails.root}/tmp", "import_#{SecureRandom.hex(10)}.zip"), 'wb+', 0600)
      temp_file.write params[:content].read
    ensure
      temp_file.close
    end

    @provider.import_manifest(File.expand_path(temp_file.path), :force => false,
                              :async => false, :notify => false)

    collection = {
      :results => @organization.pools,
      :subtotal => @organization.pools.count,
      :total => @organization.pools.count
    }
    respond_for_index(:collection => collection, :template => :index)
  end

  protected

  def find_system
    @system = System.find_by_uuid!(params[:system_id]) if params[:system_id]
  end

  def find_provider
    @provider = @organization.redhat_provider if @organization
  end

  def find_system_or_distributor
    if params[:system_id]
      find_system
      fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    elsif params[:distributor_id]
      @distributor = Distributor.find_by_uuid(params[:distributor_id])
      fail HttpErrors::NotFound, _("Couldn't find subscription manager application '%s'") %
                                 params[:distributor_id] if @distributor.nil?
    end
    @system ? @system : @distributor
  end

  def find_subscription
    @subscription = Pool.find_pool(subscriptions_params[:subscription_id])
    fail HttpErrors::NotFound, _("Couldn't find subscription '%s'") % params[:subscription_id] if @subscription.nil?
  end

  def subscriptions_params
    attrs = [:subscription_id, :quantity]
    params.require(:subscription).permit(*attrs)
  end
end
end
