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

class Api::V2::ProductsController < Api::V2::ApiController

  before_filter :find_provider, :only => [:create]
  before_filter :find_organization, :only => [:index]
  before_filter :find_product, :only => [:show, :update, :destroy]
  before_filter :authorize

  def_param_group :product do
    param :name, String, :required => true
    param :label, String, :required => false
    param :provider_id, :number, :required => true, :desc => "Provider the product belongs to"
    param :description, String, :desc => "Product description"
    param :gpg_key_id, :identifier, :desc => "identifier of the gpg key"
  end

  def rules
    index_test = lambda { Product.any_readable?(@organization) }
    create_test = lambda { @provider.nil? ? true : Product.creatable?(@provider) }
    read_test  = lambda { @product.readable? }
    edit_test  = lambda { @product.editable? }

    {
      :index => index_test,
      :create => create_test,
      :show => read_test,
      :update => edit_test,
      :destroy => edit_test
    }
  end

  def param_rules
    {
      :create => [:name, :label, :description, :provider_id, :gpg_key_id]
    }
  end

  api :GET, "/products", "List of products"
  param_group :search, Api::V2::ApiController
  def index
    options = sort_params
    options[:load_records?] = true

    ids = Product.all_readable(@organization).pluck('products.id')

    options[:filters] = [
      {:terms => {:id => ids}}
    ]

    @search_service.model = Product
    products, total_count = @search_service.retrieve(params[:search], params[:offset], options)

    collection = {
      :results  => products,
      :subtotal => total_count,
      :total    => @search_service.total_items
    }

    respond_for_index :collection => collection
  end

  api :POST, "/products", "Create a product"
  param_group :product
  def create
    params[:label] = labelize_params(params)

    product = Product.create!(params)

    respond_for_show(:resource => product)
  end

  api :GET, "/products/:id", "Show a product"
  param :id, :number, :desc => "product numeric identifier"
  def show
    respond_for_show(:resource => @product)
  end

  api :PUT, "/products/:id", "Update a product"
  param :id, :number, :desc => "product numeric identifier"
  param_group :product
  def update
    reset_gpg_keys = (params[:gpg_key_id] != @product.gpg_key_id)

    @product.update_attributes!(params)
    @product.reset_repo_gpgs! if reset_gpg_keys

    respond_for_show(:resource => @product)
  end

  api :DELETE, "/products/:id", "Destroy a product"
  param :id, :number, :desc => "product numeric identifier"
  def destroy
    @product.destroy

    respond_for_destroy
  end

  protected

  def find_provider
    @provider = Provider.find(params[:provider_id]) if params[:provider_id]
  end

  def find_product
    @product = Product.find_by_cp_id(params[:id], params[:organization_id]) if params[:id]
  end

end
