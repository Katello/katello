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
  include AutoCompleteSearch
  include KatelloUrlHelper

  respond_to :html, :js

  before_filter :find_provider, :only => [:new, :create, :edit, :destroy, :update_gpg_key]
  before_filter :find_product, :only => [:new, :create, :edit, :destroy, :update_gpg_key]
  before_filter :authorize
  before_filter :find_repository, :only => [:edit, :destroy, :enable_repo, :update_gpg_key]

  def rules
    read_any_test = lambda{Provider.any_readable?(current_organization)}
    read_test = lambda{@product.readable?}
    edit_test = lambda{@product.editable?}
    org_edit = lambda{current_organization.editable?}
    {
      :new => edit_test,
      :create => edit_test,
      :edit => read_test,
      :update_gpg_key => edit_test,
      :destroy => edit_test,
      :enable_repo => org_edit,
      :auto_complete_library => read_any_test
    }
  end

  def section_id
    'contents'
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals=>{:editable=>@product.editable?}
  end

  def create
    begin
      repo_params = params[:repo]
      raise _('Invalid Url') if !kurl_valid?(repo_params[:feed])
      gpg = GpgKey.readable(current_organization).find(repo_params[:gpg_key]) if repo_params[:gpg_key] and repo_params[:gpg_key] != ""
      # Bundle these into one call, perhaps move to Provider
      # Also fix the hard coded yum
      @product.add_repo(repo_params[:name], repo_params[:feed], 'yum', gpg)
      @product.save

      notice _("Repository '%s' created.") % repo_params[:name]
      render :nothing => true

    rescue => error
      log_exception error
      notice error, {:level => :error}
      render :text=> error.to_s, :status=>:bad_request and return
    end
  end

  def update_gpg_key
    begin
      if params[:gpg_key] != ""
        gpg = GpgKey.readable(current_organization).find(params[:gpg_key])
        result = gpg.id.to_s
      else
        gpg = nil
        result = ""
      end
      @repository.gpg_key = gpg
      @repository.save!
      notice _("Repository '%s' updated.") % @repository.name
    rescue => error
      log_exception error
      notice error, {:level => :error}
      render :text=> error.to_s, :status=>:bad_request and return
    end
    render :text => escape_html(result)
  end

  def enable_repo
    begin
      @repository.enabled = params[:repo] == "1"
      @repository.save!
      render :json => @repository.id
    rescue => error
      log_exception error
      notice error, {:level => :error}
      render :text=> error.to_s, :status=>:bad_request and return
    end
  end

  def destroy
    r = Repository.find(@repository[:id])
    name = r.name
    @product.delete_repo_by_id(@repository[:id])
    notice _("Repository '%s' removed.") % name
    render :partial => "common/post_delete_close_subpanel", :locals => {:path=>products_repos_provider_path(@provider.id)}
  end

  def auto_complete_library
    # retrieve and return a list (array) of repo names in library that contain the 'term' that was passed in
    term = Katello::Search::filter_input params[:term]
    name = 'name:' + term
    name_query = name + ' OR ' + name + '*'
    ids = Repository.readable(current_organization.library).collect{|r| r.id}
    repos = Repository.search do
      query {string name_query}
      filter "and", [
          {:terms => {:id => ids}},
          {:terms => {:enabled => [true]}}
      ]
    end

    render :json => repos.map{|repo|
      label = _("%{repo} (Product: %{product})" % {:repo => repo.name, :product => repo.product})
      {:id => repo.id, :label => label, :value => repo.name}
    }
  end

  protected

  def find_provider
    begin
      @provider = Provider.find(params[:provider_id])
    rescue => error
      log_exception error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_product
    begin
      @product = Product.find(params[:product_id])
    rescue => error
      log_exception error
      notice error.to_s, {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end

  def find_repository
    begin
      @repository = Repository.find(params[:id])
    rescue => error
      log_exception error
      notice _("Couldn't find repository with ID=%s") % params[:id], {:level => :error}
      execute_after_filters
      render :text => error, :status => :bad_request
    end
  end
end
