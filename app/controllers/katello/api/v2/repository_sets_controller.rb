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
class Api::V2::RepositorySetsController < Api::V2::ApiController
  respond_to :json

  before_filter :find_product
  before_filter :custom_product?
  before_filter :find_product_content, :except => [:index]
  before_filter :authorize

  def rules
    edit_product_test = lambda { @organization.redhat_manageable? }
    read_test         = lambda { @product.readable? }

    {
        :enable  => edit_product_test,
        :disable => edit_product_test,
        :index   => read_test,
        :show    => read_test
    }
  end

  resource_description do
    api_version "v2"
  end

  api :PUT, "/repository_sets/:id/enable", "Enable a repository set"
  api :PUT, "/products/:product_id/repository_sets/:id/enable", "Enable a repository set"
  param :id, :number, :required => true, :desc => "ID of the repository set to enable"
  param :product_id, :number, :required => true, :desc => "ID of the product containing the repository set"
  def enable
    respond_for_show :resource => @product.refresh_content(@product_content.content.id)
  end

  api :PUT, "/repository_sets/:id/disable", "Disable a repository set"
  api :PUT, "/products/:product_id/repository_sets/:id/disable", "Disable a repository set"
  param :id, :number, :required => true, :desc => "ID of the repository set to enable"
  param :product_id, :number, :required => true, :desc => "ID of the product containing the repository set"
  def disable
    respond_for_show :resource => @product.disable_content(@product_content.content.id)
  end

  api :GET, "/repository_sets", "List repository sets for a product"
  api :GET, "/products/:product_id/repository_sets", "List repository sets for a product."
  param :product_id, :number, :required => true, :desc => "ID of a product to list repository sets from"
  def index
    collection = {}
    collection[:results] = @product.productContent
    collection[:subtotal] = collection[:results].size
    collection[:total] = collection[:subtotal]
    respond_for_index :collection => collection
  end

  api :GET, "/repository_sets/:id", "Get info about a repository set"
  api :GET, "/products/:product_id/repository_sets/:id", "Get info about a repository set"
  param :id, :number, :required => true, :desc => "ID of the repository set"
  param :product_id, :number, :required => true, :desc => "ID of a product to list repository sets from"
  def show
    respond :resource => @product_content
  end

  private

  def find_product_content
    @product_content = @product.product_content_by_id(params[:id])
    fail HttpErrors::NotFound, _("Couldn't find repository set with id '%s'.") % params[:id] if @product_content.nil?
  end

  def find_product
    @product = Product.find_by_id(params[:product_id])
    fail HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
    @organization = @product.organization
  end

  def custom_product?
    fail _('Repository sets are not available for custom products.') if @product.custom?
  end

end
end
