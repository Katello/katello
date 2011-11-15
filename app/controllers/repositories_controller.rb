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

  before_filter :find_provider, :only => [:new, :create, :edit, :destroy]
  before_filter :authorize
  before_filter :find_product, :only => [:new, :create, :edit, :destroy]
  before_filter :find_repository, :only => [:edit, :destroy, :enable_repo]

  def rules
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    org_edit = lambda{current_organization.editable?}
    {
      :new => edit_test,
      :create => edit_test,
      :edit =>read_test,
      :update => edit_test,
      :destroy => edit_test,
      :enable_repo => org_edit
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
      repo_params = params[:repo]
      raise _('Invalid Url') if !kurl_valid?(repo_params[:feed])
      # Bundle these into one call, perhaps move to Provider
      # Also fix the hard coded yum
      @product.add_repo(repo_params[:name], repo_params[:feed], 'yum')
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

  def enable_repo
    @repository.enabled = params[:repo] == "1"
    @repository.save!
    if @repository.enabled?
      notice _("Repository '#{@repository.name}' enabled.")
    else
      notice _("Repository '#{@repository.name}' disabled.")
    end
    render :json => ""
  end

  def destroy
    r = Repository.find(@repository[:id])
    name = r.name
    @product.delete_repo_by_id(@repository[:id])
    notice _("Repository '#{name}' removed.")
    render :partial => "common/post_delete_close_subpanel", :locals => {:path=>products_repos_provider_path(@provider.id)}
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
      @repository = Repository.find(params[:id])
    rescue Exception => error
      errors _("Couldn't find repository with ID=#{params[:id]}")
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
end
