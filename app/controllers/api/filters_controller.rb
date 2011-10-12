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

class Api::FiltersController < Api::ApiController

  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_filter, :only => [:show, :destroy]
  before_filter :find_product, :only => [:list_product_filters, :update_product_filters]
  before_filter :authorize

  def rules
    index_filters = lambda { Filter.any_readable?(@organization) }
    create_filter = lambda { Filter.creatable?(@organization) }
    read_filter = lambda { @filter.readable? }
    delete_filter = lambda { @filter.deletable? }

    {
      :create => create_filter,
      :index => index_filters,
      :show => read_filter,
      :destroy => delete_filter
    }
  end

  def index
    render :json => @organization.filters.to_json
  end

  def create
    @filter = Filter.create!(params[:filter]) do |f|
      f.organization = @organization
    end
    render :json => @filter.to_json
  end

  def show
    render :json => @filter.to_json
  end

  def destroy
    @filter.destroy
    render :text => _("Deleted filter '#{params[:id]}'"), :status => 200
  end

  def list_product_filters
    render :json => @product.filters.to_json
  end

  def update_product_filters
    @products.filters_will_change!
    @product.filters = params[:filters]

    render :json => @products.filters.to_json
  end

  def find_product
    @product = Product.find_by_cp_id(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:product_id]}'") if @product.nil?
  end

  def find_filter
    @filter = Filter.first(:conditions => {:pulp_id => params[:id]})
    raise HttpErrors::NotFound, _("Couldn't find filter '#{params[:id]}'") if @filter.nil?
    @filter
  end

end
