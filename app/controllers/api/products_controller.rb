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
  before_filter :verify_presence_of_organization_or_environment, :only => [:index]
  before_filter :authorize

  def rules
    read_test = lambda { Product.any_readable?(@organization) }
    repo_test = lambda { @product.readable? }
    {
      :index => read_test,
      :repositories => repo_test,
    }
  end

  def show
    render :json => @product.to_json
  end

  def index
    query_params.delete(:organization_id)
    query_params.delete(:environment_id)

    render :json => Product.readable(@organization).select("products.*, providers.name AS provider_name").joins(:provider).where(query_params) if @environment == nil
    render :json => @environment.products.readable(@organization).select("products.*, providers.name AS provider_name").joins(:provider).where(query_params).all if @environment != nil
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
      @environment = @organization.locker unless @organization.nil?
      @environment = @product.organization.locker unless @product.nil?
    else
      @environment = KTEnvironment.find_by_id(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    end
    @organization ||= @environment.organization if @environment
  end

  def verify_presence_of_organization_or_environment
    return if @organization || @environment
    raise HttpErrors::BadRequest, _("Either organization id or environment id needs to be specified")
  end

end
