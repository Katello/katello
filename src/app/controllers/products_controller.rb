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

class ProductsController < ApplicationController
  respond_to :html, :js

  before_filter :find_provider, :only => [:new, :create, :edit, :update]
  before_filter :find_product, :only => [:edit, :update, :destroy]

  def section_id
    'contents'
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit"
  end

  def create
    begin
      product_params = params[:product]
      @provider.add_custom_product(product_params[:name], product_params[:description], product_params[:url])
      notice _("Product '#{product_params[:name]}' created.")
    rescue Exception => error
      Rails.logger.error error.to_s
      errors error
    end
    render :json => ""
  end

  def update
    begin
      result = params[:product].values.first

      @product.name = params[:product][:name] unless params[:product][:name].nil?
      @product.description = params[:product][:description] unless params[:product][:description].nil?

      @product.save!
      notice _("Product '#{@product.name}' was updated.")

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

    rescue Exception => e
      errors e.to_s

      respond_to do |format|
        format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def destroy
    begin
      @product.destroy
      notice _("Product '#{@product[:name]}' removed.")
    rescue Exception => error
      Rails.logger.error error.to_s
      errors error.to_s
    end
    render :json => ""
  end

  protected

  def find_provider
    @provider = Provider.find(params[:provider_id])
    errors _("Couldn't find provider '#{params[:provider_id]}'") if @provider.nil?
    redirect_to(:controller => :providers, :action => :index, :organization_id => current_organization.cp_key) and return if @provider.nil?
  end

  def find_product
    @product = Product.find(params[:id])
    errors _("Couldn't find product '#{params[:id]}'") if @product.nil?
    redirect_to(:controller => :providers, :action => :index, :organization_id => current_organization.cp_key) and return if @product.nil?
  end
end
