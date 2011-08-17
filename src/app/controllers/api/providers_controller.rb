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

require 'resources/candlepin'
require 'rest_client'

class Api::ProvidersController < Api::ApiController

  before_filter :find_organization, :only => [:create]
  before_filter :find_provider, :only => [:show, :update, :destroy, :products, :import_products, :import_manifest, :product_create]

  def index
    render :json => (Provider.where query_params).to_json
  end

  def show
    render :json => @provider.to_json
  end

  def create
    provider = Provider.create!(params[:provider]) do |p|
      p.organization = @organization
    end
    render :json => provider.to_json and return
  end

  def update
    @provider.update_attributes!(params[:provider])
    render :json => @provider.to_json and return
  end

  def destroy
    @provider.destroy
    if @provider.destroyed?
      render :text => _("Deleted provider [ %{p} ]") % {:p => @provider.name}, :status => 200
    else
      raise HttpErrors::ApiError, _("Error while deleting provider [ %{p} ]") % {:p => @provider.name}
    end
  end

  def products
    render :json => @provider.products.to_json
  end
  
  def import_manifest
    if @provider.yum_repo?
      raise HttpErrors::BadRequest, _("It is not allowed to import manifest for a custom provider.")
    end

    begin
      temp_file = File.new(File.join("#{Rails.root}/tmp", "import_#{SecureRandom.hex(10)}.zip"), 'w+', 0600)
      temp_file.write params[:import].read
    ensure
      temp_file.close
    end
    
    @provider.import_manifest File.expand_path(temp_file.path)
    render :text => "Manifest imported", :status => 200
    rescue => e
      raise HttpErrors::ApiError, _("Manifest import for provider [ %{p} ] failed") % {:p => @provider.name}
  end

  def import_products
    results = params[:products].collect do |p|
      to_create = Product.new(p) do |product|
        product.provider = @provider
        product.organization = @provider.organization
      end
      to_create.save!
    end
    render :json => results.to_json
  end

  def product_create
    product_params = params[:product]
    prod = @provider.add_custom_product(product_params[:name], product_params[:description], product_params[:url])
    render :json => prod
  end

  private

  def find_provider
    @provider = Provider.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find provider '#{params[:id]}'") if @provider.nil?
  end

end
