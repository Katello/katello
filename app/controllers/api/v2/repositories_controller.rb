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

class Api::V2::RepositoriesController < Api::V2::ApiController

  before_filter :find_organization, :only => [:index, :show]
  before_filter :find_product, :only => [:index]
  before_filter :find_product_for_create, :only => [:create]
  before_filter :find_repository, :only => [:show, :update, :destroy, :sync]
  before_filter :authorize

  def_param_group :repo do
    param :name, String, :required => true
    param :label, String, :required => false
    param :product_id, :number, :required => true, :desc => "Product the repository belongs to"
    param :url, :undef, :required => true, :desc => "repository source url"
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

  def param_rules
    {
      :create => [:name, :label, :product_id, :unprotected, :content_type,
                  :url, :gpg_key_id, :organization_id],
      :update => { :repository => [:gpg_key_name] }
    }
  end

  api :GET, "/repositories", "List of repositories"
  param :organization_id, :number, :required => true, :desc => "id of an organization to show repositories in"
  param :product_id, :number, :required => false, :desc => "id of a product to show repositories of"
  param :environment_id, :number, :required => false, :desc => "id of an environment to show repositories in"
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
      product_ids = Product.readable(@organization).pluck("products.id")
      options[:filters] << [{:terms => {:product_id => product_ids}}]
    end

    options[:filters] << {:term => {:enabled => params[:enabled]}} if params[:enabled]
    options[:filters] << {:term => {:environment_id => params[:environment_id]}} if params[:environment_id]
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
    uuid, feature = Orchestrate.trigger(Orchestrate::Katello::RepositorySync,
                                        @repository)
    render :json => { uuid: uuid }
  end

  api :PUT, "/repositories/:id", "Update a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  param :gpg_key_id, :number, :desc => "id of a gpg key that will be assigned to this repository"
  def update
    fail HttpErrors::BadRequest, _("A Red Hat repository cannot be updated.") if @repository.redhat?
    @repository.update_attributes!(params.slice(:gpg_key_id, :feed))
    respond_for_show(:resource => @repository)
  end

  api :DELETE, "/repositories/:id", "Destroy a repository"
  param :id, :identifier, :required => true
  def destroy
    @repository.destroy

    respond_for_destroy
  end

  protected

  def find_product
    @product = Product.find_by_cp_id(params[:product_id], @organization) if params[:product_id]
  end

  def find_product_for_create
    #Since we're using cp_id, product happens to be unique per org
    @product = Product.find_by_cp_id(params[:product_id]) if params[:product_id]
  end

  def find_repository
    @repository = Repository.find(params[:id]) if params[:id]
  end

end
