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

class RepositoriesController < ApplicationController

  include KatelloUrlHelper

  respond_to :html, :js

  before_filter :find_provider, :only => [:edit, :update, :destroy, :new, :create]
  before_filter :authorize
  before_filter :find_product, :only => [:edit, :update, :destroy, :new, :create]
  before_filter :find_repository, :only => [:edit, :update, :destroy]

  def rules
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    {
      :new => edit_test,
      :create => edit_test,
      :edit =>read_test,
      :update => edit_test,
      :destroy => edit_test,
    }
  end

  

  def section_id
    'contents'
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout"
  end

  def create
    begin
      repo_params = params[:repo]
      raise _('Invalid Url') if !kurl_valid?(repo_params[:feed])
      # Bundle these into one call, perhaps move to Provider
      # Also fix the hard coded yum
      @product.add_new_content(repo_params[:name], repo_params[:feed], 'yum')
      @product.save

    rescue Exception => error
      Rails.logger.error error.to_s
      errors error 
      render :text=> error.to_s, :status=>:bad_request and return
    end
    notice _("Repository '#{repo_params[:name]}' created.")
    render :json => ""
  end

  def update
  end

  def destroy
    @product.delete_repo(params[:id])
    notice _("Repository '#{params[:id]}' removed.")
    render :json => ""
  end

  protected

  def find_provider
    begin
      @provider = Provider.find(params[:provider_id])
    rescue Exception => error
      errors error.to_s
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_product
    begin
      @product = Product.find(params[:product_id])
    rescue Exception => error
      errors error.to_s
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_repository
    begin
      @repository = Pulp::Repository.find @product.repo_id(params[:id])
    rescue Exception => error
      errors _("Couldn't find repository with ID=#{params[:id]}")
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
end
