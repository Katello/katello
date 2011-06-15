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

require 'resources/pulp'

class Api::RepositoriesController < Api::ApiController
  respond_to :json
  before_filter :find_repository, :only => [:show]
  before_filter :find_product, :only => [:create]
  
  def create
    # create product content in Candlepin
    productContent = @product.add_new_content(params[:name], params[:url], 'yum')
    # let glue layer to create repo in Pulp
    @product.save
    
    render_to_json(productContent)
  end

  def index
    repos = Pulp::Repository.all
    render :json => repos
  end

  def show
    render :json => @repository
  end
  
  def find_repository
    @repository = Pulp::Repository.find params[:id]
    render :text => _("Couldn't find repository '#{params[:id]}'"), :status => 404 and return if @repository.nil?
    @repository
  end
  
  def find_product
    @product = Product.find_by_cp_id params[:product_id]
    render(:text => _("Couldn't find product with id '#{params[:product_id]}'"), :status => 404) and return if @product.nil?
  end
end
