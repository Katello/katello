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

class Api::V1::RepositorySetsController < Api::V1::ApiController
  respond_to :json

  before_filter :find_organization, :only => [:enable, :disable, :index]
  before_filter :find_product, :only => [:enable, :disable, :index]
  before_filter :find_product_content, :only=> [:enable, :disable]

  before_filter :authorize


  def rules
    edit_product_test = lambda{@product.editable?}
    read_test = lambda{@product.readable?}
    {
      :enable => edit_product_test,
      :disable => edit_product_test,
      :index => read_test,
    }
  end


  api :POST, "/product/:product_id/repository_set/:id/enable", "Enable a repository set for a product."
  param :organization_id, :identifier, :required => true, :desc => "id of an organization the repository will be contained in"
  param :product_id, :number, :required => true, :desc => "id of a product the repository will be contained in"
  param :id, :number, :required => true, :desc => "id or name of the repository set to enable"
  def enable
    raise _('Repository sets are enabled by default for custom products..') if @product.custom?
    render :json=>@product.async(:organization=>@organization).refresh_content(@product_content.content.id)
  end

  api :POST, "/product/:product_id/repository_set/:id/disable", "Enable a repository set for a product."
  param :organization_id, :identifier, :required => true, :desc => "id of an organization the repository will be contained in"
  param :product_id, :number, :required => true, :desc => "id of a product the repository will be contained in"
  param :id, :number, :required => true, :desc => "id of the repository set to disable"
  def disable
    raise _('Repository sets are not applicable for custom products..') if @product.custom?
    render :json=>@product.async(:organization=>@organization).disable_content(@product_content.content.id)
  end

  api :GET, "/product/:product_id/repository_set/", "List repository sets for a product."
  param :organization_id, :identifier, :required => true, :desc => "id of an "
  param :product_id, :number, :required => true, :desc => "id of a product to list repository sets in"
  def index
    raise _('Repository sets are not available for custom products.') if @product.custom?
    content = @product.productContent.collect do |pc|
          content = pc.content.as_json
          content[:katello_enabled] = pc.katello_enabled?
          content
        end
    render :json=>content
  end

  private

  def find_product_content
    @product_content = @product.product_content_by_id(params[:id])
    @product_content ||= @product.product_content_by_name(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find repository set with id.") % params[:id] if @product_content.nil?
  end

  def find_product
    @product = @organization.products.find_by_cp_id(params[:product_id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
  end
end
