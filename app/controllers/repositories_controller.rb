#
# Copyright 2013 Red Hat, Inc.
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
      :default_label => lambda{true},
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
    render :partial => "new"
  end

  def edit
    render :partial => "edit",
           :locals=>{
               :editable=> (@product.editable? and !@repository.promoted?),
               :cloned_in_environments => @repository.product.environments.select {|env| @repository.is_cloned_in?(env)}.map(&:name)
           }
  end

  def create
    repo_params = params[:repo]
    repo_params[:label], label_assigned = generate_label(repo_params[:name], 'repository') if repo_params[:label].blank?

    raise HttpErrors::BadRequest, _("Repository can be only created for custom provider.") unless @product.custom?

    gpg = GpgKey.readable(current_organization).find(repo_params[:gpg_key]) if repo_params[:gpg_key] and repo_params[:gpg_key] != ""
    # Bundle these into one call, perhaps move to Provider

    repo_params[:unprotected] ||= false
    @product.add_repo(repo_params[:label],repo_params[:name], repo_params[:feed],
                      repo_params[:content_type], repo_params[:unprotected], gpg)
    @product.save!

    notify.success _("Repository '%s' created.") % repo_params[:name] unless params[:ignore_success_notice]
    notify.message label_assigned unless label_assigned.blank? unless params[:ignore_success_notice]

    render :nothing => true
  rescue Errors::ConflictException, ActiveRecord::RecordInvalid, Glue::Pulp::PulpErrors::ServiceUnavailable => e
    e.class == Glue::Pulp::PulpErrors::ServiceUnavailable ? notify.exception(e) : notify.error(e.to_s)
    execute_after_filters
    render :nothing => true, :status => :bad_request
  end

  def update_gpg_key
    if params[:gpg_key] != ""
      gpg = GpgKey.readable(current_organization).find(params[:gpg_key])
      result = gpg.id.to_s
    else
      gpg = nil
      result = ""
    end
    @repository.gpg_key = gpg
    @repository.save!
    notify.success _("Repository '%s' updated.") % @repository.name
    render :text => escape_html(result)
  end

  def enable_repo
    @repository.enabled = params[:repo] == "1"
    @repository.save!
    product_content = @repository.product.product_content_by_id(@repository.content_id)
    render :json => {:id=>@repository.id, :can_disable_repo_set=>product_content.can_disable?}
  end

  def destroy
    @repository.destroy
    if @repository.destroyed?
      notify.success _("Repository '%s' removed.") % @repository.name
      render :partial => "common/post_delete_close_subpanel", :locals => {:path=>products_repos_provider_path(@provider.id)}
    else
      err_msg = N_("Removal of the repository failed. If you continue having trouble with this, please contact an Administrator.")
      notify.error err_msg
      render :nothing => true
    end
  end

  def auto_complete_library
    # retrieve and return a list (array) of repo names in library that contain the 'term' that was passed in
    term = Util::Search::filter_input params[:term]
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
      label = _("%{repo} (Product: %{product})") % {:repo => repo.name, :product => repo.product}
      {:id => repo.id, :label => label, :value => repo.name}
    }
  end

  protected

  def find_provider
    @provider = Provider.find(params[:provider_id])
  end

  def find_product
    @product = Product.find(params[:product_id])
  end

  def find_repository
    @repository = Repository.find(params[:id])
  end
end
