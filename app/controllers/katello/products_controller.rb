#
# Copyright 2014 Red Hat, Inc.
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
class ProductsController < Katello::ApplicationController
  respond_to :html, :js

  before_filter :find_product, :only => [:refresh_content, :disable_content]
  before_filter :find_provider, :only => [:refresh_content, :disable_content]

  before_filter :authorize

  def rules
    read_test = lambda {Product.any_readable?(current_organization)}
    edit_test = lambda{@provider.editable?}

    {
      :auto_complete =>  read_test,
      :refresh_content => edit_test,
      :disable_content => edit_test,
    }
  end

  def section_id
    'contents'
  end

  def refresh_content
    if @product.custom?
      render_bad_parameters _('Repository sets are enabled by default for custom products.')
    else
      pc = @product.refresh_content(params[:content_id])
      render :partial => 'katello/providers/redhat/repos', :locals => { :product_content => pc }
    end
  end

  def disable_content
    if @product.custom?
      render_bad_parameters _('Repository sets cannot be disabled for custom products.')
    else
      render :json => @product.disable_content(params[:content_id])
    end
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
    render :json => products.collect{|s| {:label => s.name, :value => s.name, :id => s.id}}
  rescue Tire::Search::SearchRequestFailed
    render :json => Util::Support.array_with_total
  end

  private

  def find_provider
    @provider = @product.provider if @product #don't trust the provider_id coming in if we don't need it
    @provider ||= Provider.find(params[:provider_id])
  end

  def find_product
    @product = Product.find(params[:id])
  end
end
end
