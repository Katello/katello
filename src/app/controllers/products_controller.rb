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

  before_filter :find_product, :only => [:edit, :update, :destroy]
  before_filter :find_provider, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :authorize

  def rules
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    auto_complete_test = lambda {Product.any_readable?(current_organization)}

    {
      :new => edit_test,
      :create => edit_test,
      :edit =>read_test,
      :update => edit_test,
      :destroy => edit_test,
      :auto_complete=>  auto_complete_test
    }
  end


  def section_id
    'contents'
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals=>{:editable=>@provider.editable?}
  end

  def create
    begin
      product_params = params[:product]
      gpg = GpgKey.readable(current_organization).find(product_params[:gpg_key]) if product_params[:gpg_key] and product_params[:gpg_key] != ""
      @provider.add_custom_product(product_params[:name], product_params[:description], product_params[:url], gpg)

      notice _("Product '%s' created.") % product_params[:name]
      render :nothing => true

    rescue Exception => error
      Rails.logger.error error.to_s
      notice error, {:level => :error}
      render :text => error, :status => :bad_request
    end
  end

  def update
    begin
      result = params[:product].values.first
      @product.name = params[:product][:name] if params[:product][:name]
      @product.description = params[:product][:description] if params[:product][:description]
      
      if params[:product].has_key?(:gpg_key)
        if params[:product][:gpg_key] != ""
          @product.gpg_key = GpgKey.readable(current_organization).find(params[:product][:gpg_key])
          result = @product.gpg_key.id.to_s
        else
          @product.gpg_key = nil
          result = ""
        end
      end 
      
      if params[:product].has_key?(:gpg_all_repos)
        notice _("All repository GPG keys for Product '%s' were updated.") % @product.name
        @product.reset_repo_gpgs!
      else
        notice _("Product '%s' was updated.") % @product.name
      end
      
      @product.save!

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

    rescue Exception => e
      notice e.to_s, {:level => :error}

      respond_to do |format|
        format.html { render :partial => "common/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.json { render :partial => "common/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def destroy
    begin
      @product.destroy
      notice _("Product '%s' removed.") % @product[:name]
    rescue Exception => error
      Rails.logger.error error.to_s
      notice error.to_s, {:level => :error}
    end
    render :partial => "common/post_delete_close_subpanel", :locals => {:path=>products_repos_provider_path(@product.provider_id)}
  end

  def auto_complete
    query = "name_autocomplete:#{params[:term]}"
    org = current_organization
    products = Product.search do
      query do
        string query
      end
      filter :term, {:organization_id => org.id}
    end
    render :json=>products.collect{|s| {:label=>s.name, :value=>s.name, :id=>s.id}}
  end



  protected

  def find_provider
    begin
      @provider = @product.provider if @product  #don't trust the provider_id coming in if we don't need it
      @provider ||= Provider.find(params[:provider_id])
    rescue Exception => error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_product
    begin
      @product = Product.find(params[:id])
    rescue Exception => error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
end
