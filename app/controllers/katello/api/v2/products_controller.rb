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

    before_filter :find_or_create_provider, :only => [:create]
    before_filter :find_organization, :only => [:index]
    before_filter :find_product, :only => [:update, :destroy, :show]
    before_filter :authorize

    resource_description do
      api_version "v2"
    end

    def_param_group :product do
      param :description, String, :desc => "Product description"
      param :gpg_key_id, :number, :desc => "Identifier of the GPG key"
      param :sync_plan_id, :number, :desc => "Plan numeric identifier", :allow_nil => true
    end

    def rules
      index_test = lambda { Product.any_readable?(@organization) }
      create_test = lambda { @provider.nil? ? true : Product.creatable?(@provider) }
      read_test  = lambda { @product.readable? }
      edit_test  = lambda { @product.editable? || @product.syncable? }
      delete_test = lambda { @product.deletable?}

      {
        :index => index_test,
        :create => create_test,
        :show => read_test,
        :update => edit_test,
        :destroy => delete_test
      }
    end

    api :GET, "/products", "List products"
    api :GET, "/subscriptions/:subscription_id/products", "List of subscription products in an organization"
    api :GET, "/organizations/:organization_id/products", "List of products in an organization"
    param :organization_id, :identifier, :desc => "Filter products by organization", :required => true
    param :subscription_id, :identifier, :desc => "Filter products by subscription"
    param :name, String, :desc => "Filter products by name"
    param :enabled, :bool, :desc => "Filter products by enabled or disabled"
    param_group :search, Api::V2::ApiController
    def index
      options = {
        :filters => [],
        :load_records? => true
      }

      options[:filters] << {:terms => {:id => filter_by_subscription(params[:subscription_id])}}
      options[:filters] << {:term => {:name => params[:name].downcase}} if params[:name]
      options[:filters] << {:term => {:enabled => params[:enabled].to_bool}} if params[:enabled]
      options.merge!(sort_params)
      respond(:collection => item_search(Product, params, options))
    end

    api :POST, "/products", "Create a product"
    param :organization_id, :identifier, "ID of the organization", :required => true
    param_group :product
    param :name, String, :desc => "Product name", :required => true
    param :label, String, :required => false
    def create
      params[:product][:label] = labelize_params(product_params) if product_params
      params[:product][:provider_id] ||= @provider.id
      product = Product.create!(product_params)

      respond(:resource => product)
    end

    api :GET, "/products/:id", "Show a product"
    param :id, :number, :desc => "product numeric identifier", :required => true
    def show
      respond_for_show(:resource => @product)
    end

    api :PUT, "/products/:id", "Updates a product"
    param :id, :number, :desc => "product numeric identifier", :required => true, :allow_nil => false
    param_group :product
    param :name, String, :desc => "Product name"
    def update
      reset_gpg_keys = (product_params[:gpg_key_id] != @product.gpg_key_id)
      @product.reset_repo_gpgs! if reset_gpg_keys
      @product.update_attributes!(product_params)

      respond(:resource => @product.reload)
    end

    api :DELETE, "/products/:id", "Destroy a product"
    param :id, :number, :desc => "product numeric identifier"
    def destroy
      @product.destroy

      respond
    end

    protected

    def find_or_create_provider
      @provider = Provider.find(product_params[:provider_id]) if product_params[:provider_id]
      @provider ||= Provider.create_anonymous!(find_organization)
    end

    def find_product
      @product = Product.find_by_id(params[:id]) if params[:id]
    end

    def filter_by_subscription(subscription_id = nil)
      ids = Product.all_readable(@organization).pluck(:id)
      if subscription_id
        @subscription = Pool.find_by_organization_and_id!(@organization, subscription_id)
        ids &= @subscription.products.pluck("#{Product.table_name}.id")
      end
      ids
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
