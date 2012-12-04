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
  before_filter :find_provider, :only => [:new, :create, :default_label, :edit, :update, :destroy]
  before_filter :authorize

  def rules
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    auto_complete_test = lambda {Product.any_readable?(current_organization)}

    {
      :new => edit_test,
      :create => edit_test,
      :default_label => edit_test,
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
    product_params = params[:product]
    requested_label = String.new(product_params[:label]) unless product_params[:label].blank?
    product_params[:label], label_assigned = generate_label(product_params[:name], _('product')) if product_params[:label].blank?


    gpg = GpgKey.readable(current_organization).find(product_params[:gpg_key]) if product_params[:gpg_key] and product_params[:gpg_key] != ""
    product = @provider.add_custom_product(product_params[:label], product_params[:name],
                                           product_params[:description], product_params[:url], gpg)

    notify.success _("Product '%s' created.") % product_params[:name]

    if requested_label.blank?
      notify.message default_label_assigned(product)
    elsif requested_label != product.label
      notify.message label_overridden(product, requested_label)
    end

    render :nothing => true
  end

  def update
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
      notify.success _("All repository GPG keys for Product '%s' were updated.") % @product.name
      @product.reset_repo_gpgs!
    else
      notify.success _("Product '%s' was updated.") % @product.name
    end

    @product.save!

    render :text => escape_html(result)
  end

  def destroy
    @product.destroy
    notify.success _("Product '%s' removed.") % @product[:name]
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
  rescue Tire::Search::SearchRequestFailed => e
    render :json=>Support.array_with_total
  end

  protected

  def find_provider
    @provider = @product.provider if @product  #don't trust the provider_id coming in if we don't need it
    @provider ||= Provider.find(params[:provider_id])
  end

  def find_product
    @product = Product.find(params[:id])
  end
end
