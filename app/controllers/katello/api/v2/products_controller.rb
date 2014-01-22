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
  class Api::V2::ProductsController < Api::V2::ApiController

    before_filter :find_provider, :only => [:create]
    before_filter :find_organization, :only => [:index]
    before_filter :find_product, :only => [:update, :destroy, :show]
    before_filter :authorize

    def_param_group :product do
      param :name, String, :required => true
      param :label, String, :required => false
      param :provider_id, :number, :required => true, :desc => "Provider the product belongs to"
      param :description, String, :desc => "Product description"
      param :gpg_key_id, :number, :desc => "Identifier of the GPG key"
      param :sync_plan_id, :number, :desc => "Plan numeric identifier", :allow_nil => true
    end

    def rules
      index_test = lambda { Product.any_readable?(@organization) }
      create_test = lambda { @provider.nil? ? true : Product.creatable?(@provider) }
      read_test  = lambda { @product.readable? }
      edit_test  = lambda { @product.editable? || @product.syncable? }

      {
        :index => index_test,
        :create => create_test,
        :show => read_test,
        :update => edit_test,
        :destroy => edit_test
      }
    end

    api :GET, "/products", "List of organization products"
    api :GET, "/subscriptions/:subscription_id/products", "List of subscription products in an organization"
    api :GET, "/organizations/:organization_id/products", "List of products in an organization"
    param :name, :identifier, :desc => "Filter products by name"
    param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
    param :subscription_id, :number, :desc => "Filter products by subscription identifier"
    param_group :search, Api::V2::ApiController
    def index
      filters = [filter_terms(product_ids_filter)]
      # TODO: support enabled filter in products. Product currently has
      # an enabled method, and elasticsearch has mappings, but filtering
      # errors. See elasticsearch output.
      # filters << filter_terms(enabled_filter) if enabled_filter.present?
      options = sort_params.merge(:filters => filters, :load_records? => true)
      @collection = item_search(Product, params, options)
      respond_for_index(:collection => @collection)
    end

    api :POST, "/products", "Create a product"
    param_group :product
    def create
      params[:product][:label] = labelize_params(product_params) if product_params
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
    def update
      fail HttpErrors::BadRequest, _("Red Hat products cannot be updated.") if @product.redhat?

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

    def find_provider
      @provider = Provider.find(product_params[:provider_id]) if product_params[:provider_id] || organization.provider
    end

    def find_product
      @product = Product.find_by_id(params[:id]) if params[:id]
    end

    def product_ids_filter
      ids = Product.all_readable(@organization).pluck(:id)
      if (subscription_id = params[:subscription_id])
        @subscription = Pool.find_by_organization_and_id!(@organization, subscription_id)
        ids &= @subscription.products.pluck("#{Product.table_name}.id")
      end
      {:id => ids}
    end

    def product_params
      params.require(:product).permit(:name, :label, :description, :provider_id, :gpg_key_id, :sync_plan_id)
    end

    def enabled_filter
      if (enabled = params[:enabled])
        {:enabled => enabled}
      end
    end

    def filter_terms(terms)
      {:terms => terms}
    end

  end
end
