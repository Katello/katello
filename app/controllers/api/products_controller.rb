#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::ProductsController < Api::ApiController
  respond_to :json
  before_filter :find_organization, :only => [:index]
  before_filter :find_product, :only => [:repositories, :show]
  before_filter :find_environment, :only => [:index, :repositories]

  def show
    render :json => @product.to_json
  end

  def index
    query_params.delete(:organization_id)
    query_params.delete(:environment_id)

    render :json => (@environment.products.where query_params).to_json
  end

  def repositories
    render :json => @product.repos(@environment)
  end

  private

  def find_product
    @product = Product.find_by_cp_id(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:id]}'") if @product.nil?
  end

  def find_environment
    if params[:environment_id].nil?
      return @environment = @organization.locker unless @organization.nil?
      return @environment = @product.organization.locker
    end
    @environment = KPEnvironment.find(params[:environment_id])
  end
end
