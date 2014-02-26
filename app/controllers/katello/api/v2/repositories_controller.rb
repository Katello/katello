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

module Katello
class Api::V2::RepositoriesController < Api::V2::ApiController

  before_filter :find_organization, :only => [:index]
  before_filter :find_product, :only => [:index]
  before_filter :find_product_for_create, :only => [:create]
  before_filter :find_repository, :only => [:show, :update, :destroy, :sync]
  before_filter :authorize

  def_param_group :repo do
    param :name, String, :required => true
    param :label, String, :required => false
    param :product_id, :number, :required => true, :desc => "Product the repository belongs to"
    param :url, String, :required => true, :desc => "repository source url"
    param :gpg_key_name, String, :desc => "name of a gpg key that will be assigned to the new repository"
    param :enabled, :bool, :desc => "flag that enables/disables the repository"
    param :content_type, String, :desc => "type of repo (either 'yum' or 'puppet', defaults to 'yum')"
  end

  def rules
    index_test  = lambda { Repository.any_readable?(@organization) }
    create_test = lambda { Repository.creatable?(@product) }
    read_test   = lambda { @repository.readable? }
    edit_test   = lambda { @repository.editable? }
    sync_test   = lambda { @repository.syncable? }

    {
      :index    => index_test,
      :create   => create_test,
      :show     => read_test,
      :sync     => edit_test,
      :update   => edit_test,
      :destroy  => edit_test,
      :sync     => sync_test
    }
  end

  api :GET, "/repositories", "List of repositories"
  api :GET, "/content_views/:id/repositories", "List of repositories for a content view"
  param :organization_id, :number, :required => true, :desc => "id of an organization to show repositories in"
  param :product_id, :number, :required => false, :desc => "id of a product to show repositories of"
  param :environment_id, :number, :required => false, :desc => "id of an environment to show repositories in"
  param :content_view_id, :number, :required => false, :desc => "id of a content view to show repositories in"
  param :library, :bool, :required => false, :desc => "show repositories in Library and the default content view"
  param :enabled, :bool, :required => false, :desc => "limit to only enabled repositories"
  param_group :search, Api::V2::ApiController
  def index
    options = sort_params
    options[:load_records?] = true
    options[:filters] = []

    if @product
      options[:filters] << {:term => {:product_id => @product.id}}
    else
      product_ids = Product.readable(@organization).pluck("#{Product.table_name}.id")
      options[:filters] << {:terms => {:product_id => product_ids}}
    end

    options[:filters] << {:term => {:enabled => params[:enabled]}} if params[:enabled]
    options[:filters] << {:term => {:environment_id => params[:environment_id]}} if params[:environment_id]
    options[:filters] << {:term => {:content_view_ids => params[:content_view_id]}} if params[:content_view_id]
    options[:filters] << {:term => {:content_view_version_id => @organization.default_content_view.versions.first.id}} if params[:library]

    @search_service.model = Repository
    repositories, total_count = @search_service.retrieve(params[:search], params[:offset], options)

    collection = {
      :results  => repositories,
      :subtotal => total_count,
      :total    => @search_service.total_items
    }

    respond_for_index :collection => collection
  end

  api :POST, "/repositories", "Create a repository"
  param_group :repo
  def create
    params[:label] = labelize_params(params)
    gpg_key = @product.gpg_key
    unless params[:gpg_key_id].blank?
      gpg_key = GpgKey.find(params[:gpg_key_id])
    end

    repository = @product.add_repo(params[:label], params[:name], params[:url],
                                   params[:content_type], params[:unprotected], gpg_key)
    trigger(::Actions::Katello::Repository::Create, repository)
    respond_for_show(:resource => repository)
  end

  api :GET, "/repositories/:id", "Show a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  def show
    respond_for_show(:resource => @repository)
  end

  api :POST, "/repositories/:id/sync", "Sync a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  def sync
    task = async_task(::Actions::Katello::Repository::Sync, @repository)
    respond_for_async :resource => task
  end

  api :PUT, "/repositories/:id", "Update a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  param :gpg_key_id, :number, :desc => "id of a gpg key that will be assigned to this repository"
  def update
    fail HttpErrors::BadRequest, _("A Red Hat repository cannot be updated.") if @repository.redhat?
    @repository.update_attributes!(repository_params)
    respond_for_show(:resource => @repository)
  end

  api :DELETE, "/repositories/:id", "Destroy a repository"
  param :id, :identifier, :required => true
  def destroy
    trigger(::Actions::Katello::Repository::Destroy, @repository)

    respond_for_destroy
  end

  protected

  def find_product
    @product = Product.find(params[:product_id]) if params[:product_id]
  end

  def find_product_for_create
    @product = Product.find(params[:product_id])
  end

  def find_repository
    @repository = Repository.find(params[:id]) if params[:id]
  end

  def repository_params
    params.require(:repository).permit(:feed, :gpg_key_id, :unprotected)
  end

end
end
