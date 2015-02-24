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
  class Api::V2::ProductsController < Api::V2::ApiController
    before_filter :find_activation_key, :only => [:index]
    before_filter :find_system, :only => [:index]
    before_filter :find_organization, :only => [:create, :index]
    before_filter :find_product, :only => [:update, :destroy, :show, :sync]
    before_filter :find_organization_from_product, :only => [:update]
    before_filter :authorize_gpg_key, :only => [:update, :create]

    resource_description do
      api_version "v2"
    end

    def_param_group :product do
      param :description, String, :desc => N_("Product description")
      param :gpg_key_id, :number, :desc => N_("Identifier of the GPG key")
      param :sync_plan_id, :number, :desc => N_("Plan numeric identifier"), :allow_nil => true
    end

    api :GET, "/products", N_("List products")
    api :GET, "/subscriptions/:subscription_id/products", N_("List of subscription products in a subscription")
    api :GET, "/activation_keys/:activation_key_id/products", N_("List of subscription products in an activation key")
    api :GET, "/organizations/:organization_id/products", N_("List of products in an organization")
    param :organization_id, :number, :desc => N_("Filter products by organization"), :required => true
    param :subscription_id, :identifier, :desc => N_("Filter products by subscription")
    param :name, String, :desc => N_("Filter products by name")
    param :enabled, :bool, :desc => N_("Filter products by enabled or disabled")
    param :custom, :bool, :desc => N_("Filter products by custom")
    param_group :search, Api::V2::ApiController
    def index
      options = {
        :filters => [],
        :load_records? => true
      }
      products = Product.readable.where(:organization_id => @organization.id)
      products = products.where(:provider_id => @organization.anonymous_provider.id) if params[:custom]

      ids = products.pluck(:id)
      ids = filter_by_subscription(ids, params[:subscription_id]) if params[:subscription_id]
      ids = filter_by_activation_key(ids, @activation_key) if @activation_key
      ids = filter_by_system(ids, @system) if @system

      options[:filters] << {:terms => {:id => ids}}
      options[:filters] << {:term => {:name => params[:name]}} if params[:name]
      options[:filters] << {:term => {:enabled => params[:enabled].to_bool}} if params[:enabled]
      options.merge!(sort_params)
      options[:includes] = [:repositories, :gpg_key, :sync_plan, :provider]

      respond(:collection => item_search(Product, params, options))
    end

    api :POST, "/products", N_("Create a product")
    param :organization_id, :number, N_("ID of the organization"), :required => true
    param_group :product
    param :name, String, :desc => N_("Product name"), :required => true
    param :label, String, :required => false
    def create
      params[:product][:label] = labelize_params(product_params) if product_params

      product = Product.new(product_params)

      sync_task(::Actions::Katello::Product::Create, product, @organization)
      respond(:resource => product)
    end

    api :GET, "/products/:id", N_("Show a product")
    param :id, :number, :desc => N_("product numeric identifier"), :required => true
    def show
      respond_for_show(:resource => @product)
    end

    api :PUT, "/products/:id", N_("Updates a product")
    param :id, :number, :desc => N_("product numeric identifier"), :required => true, :allow_nil => false
    param_group :product
    param :name, String, :desc => N_("Product name")
    def update
      sync_task(::Actions::Katello::Product::Update, @product, product_params)

      respond(:resource => @product.reload)
    end

    api :DELETE, "/products/:id", N_("Destroy a product")
    param :id, :number, :desc => N_("product numeric identifier")
    def destroy
      task = async_task(::Actions::Katello::Product::Destroy, @product)
      respond_for_async :resource => task
    end

    api :POST, "/products/:id/sync", "Sync a repository"
    param :id, :identifier, :required => true, :desc => "product ID"
    def sync
      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Repository::Sync,
                        @product.library_repositories.has_url.syncable)

      respond_for_async(:resource => task)
    end

    protected

    def find_product
      @product = Product.find_by_id(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find product '%s'") % params[:id] unless @product
    end

    def find_activation_key
      if params[:activation_key_id]
        @activation_key = ActivationKey.find_by_id(params[:activation_key_id])
        fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % params[:activation_key_id] if @activation_key.nil?
        @organization = @activation_key.organization
      end
    end

    def find_system
      if params[:system_id]
        @system = System.find_by_uuid(params[:system_id])
        fail HttpErrors::NotFound, _("Couldn't find content host '%s'") % params[:system_id] if @system.nil?
        @organization = @system.organization
      end
    end

    def filter_by_subscription(ids, subscription_id)
      @subscription = Pool.find_by_id!(subscription_id)
      ids & @subscription.products.pluck("#{Product.table_name}.id")
    end

    def filter_by_activation_key(ids = [], activation_key)
      ids & activation_key.products.map { |product| product.id }
    end

    def find_organization_from_product
      @organization = @product.organization
    end

    def authorize_gpg_key
      gpg_key_id = product_params[:gpg_key_id]
      if gpg_key_id
        gpg_key = GpgKey.readable.where(:id => gpg_key_id, :organization_id => @organization).first
        fail HttpErrors::NotFound, _("Couldn't find gpg key '%s'") % gpg_key_id if gpg_key.nil?
      end
    end

    def filter_by_system(ids = [], system)
      ids & system.products.map { |product| product.id }
    end

    def product_params
      # only allow sync plan id to be updated if the product is a Red Hat product
      if @product && @product.redhat?
        params.require(:product).permit(:sync_plan_id)
      else
        params.require(:product).permit(:name, :label, :description, :provider_id, :gpg_key_id, :sync_plan_id)
      end
    end
  end
end
