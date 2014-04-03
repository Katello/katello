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
class Api::V2::RepositoriesController < Api::V2::ApiController

  before_filter :find_organization, :only => [:index]
  before_filter :find_product, :only => [:index]
  before_filter :find_product_for_create, :only => [:create]
  before_filter :find_organization_from_product, :only => [:create]
  before_filter :find_repository, :only => [:show, :update, :destroy, :sync, :enable, :disable]
  before_filter :find_organization_from_repo, :only => [:update, :enable, :disable]
  before_filter :find_gpg_key, :only => [:create, :update]
  before_filter :error_on_rh_product, :only => [:create]
  before_filter :error_on_rh_repo, :only => [:update, :destroy]
  before_filter :authorize

  skip_before_filter :authorize, :only => [:sync_complete]
  skip_before_filter :require_org, :only => [:sync_complete]
  skip_before_filter :require_user, :only => [:sync_complete]

  wrap_parameters :include => (Repository.attribute_names + ["url"])

  def_param_group :repo do
    param :name, String, :required => true
    param :label, String, :required => false
    param :product_id, :number, :required => true, :desc => "Product the repository belongs to"
    param :url, String, :required => true, :desc => "repository source url"
    param :gpg_key_id, :number, :desc => "id of the gpg key that will be assigned to the new repository"
    param :unprotected, :bool, :desc => "true if this repository can be published via HTTP"
    param :content_type, String, :desc => "type of repo (either 'yum' or 'puppet', defaults to 'yum')"
  end

  def rules
    index_test  = lambda { Repository.any_readable?(@organization) }
    create_test = lambda { Repository.creatable?(@product) }
    read_test   = lambda { @repository.readable? }
    edit_test   = lambda { @repository.editable? }
    sync_test   = lambda { @repository.syncable? }
    org_edit = lambda{@organization.redhat_manageable?}
    {
      :index    => index_test,
      :create   => create_test,
      :show     => read_test,
      :sync     => edit_test,
      :enable => org_edit,
      :disable => org_edit,
      :update   => edit_test,
      :destroy  => edit_test,
      :sync     => sync_test
    }
  end

  api :GET, "/repositories", "List of enabled repositories"
  api :GET, "/content_views/:id/repositories", "List of repositories for a content view"
  param :organization_id, :number, :required => true, :desc => "ID of an organization to show repositories in"
  param :product_id, :number, :desc => "ID of a product to show repositories of"
  param :environment_id, :number, :desc => "ID of an environment to show repositories in"
  param :content_view_id, :number, :desc => "ID of a content view to show repositories in"
  param :library, :bool, :desc => "show repositories in Library and the default content view"
  param :disabled, :bool, :desc => "limit to only disabled repositories"
  param :all, :bool, :desc => "display both enabled or disabled repositories"
  param :content_type, String, :desc => "limit to only repositories of this time"
  param_group :search, Api::V2::ApiController
  def index
    options = sort_params
    options[:load_records?] = true
    options[:filters] = []

    if @product
      options[:filters] << {:term => {:product_id => @product.id}}
    else
      product_ids = Product.all_readable_in_library(@organization).pluck("#{Product.table_name}.id")
      options[:filters] << {:terms => {:product_id => product_ids}}
    end

    if params[:disabled] && params[:disabled].to_bool
      options[:filters] << {:term => {:enabled => false}}
    elsif !params[:all] || !params[:all].to_bool
      options[:filters] << {:term => {:enabled => true}}
    end

    options[:filters] << {:term => {:environment_id => params[:environment_id]}} if params[:environment_id]
    options[:filters] << {:term => {:content_view_ids => params[:content_view_id]}} if params[:content_view_id]
    options[:filters] << {:term => {:content_view_version_id => @organization.default_content_view.versions.first.id}} if params[:library]
    options[:filters] << {:term => {:content_type => params[:content_type]}} if params[:content_type]

    respond :collection => item_search(Repository, params, options)

  end

  api :POST, "/repositories", "Create a custom repository"
  param_group :repo
  def create
    params[:label] = labelize_params(params)
    gpg_key = @product.gpg_key
    unless params[:gpg_key_id].blank?
      gpg_key = @gpg_key
    end

    repository = @product.add_repo(params[:label], params[:name], params[:url],
                                   params[:content_type], params[:unprotected], gpg_key)
    sync_task(::Actions::Katello::Repository::Create, repository)
    repository = Repository.find(repository.id)
    respond_for_show(:resource => repository)
  end

  api :GET, "/repositories/:id", "Show a custom repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  def show
    respond_for_show(:resource => @repository)
  end

  api :POST, "/repositories/:id/sync", "Sync a repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  def sync
    task = async_task(::Actions::Katello::Repository::Sync, @repository)
    respond_for_async :resource => task
  end

  api :PUT, "/repositories/:id", "Update a custom repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  param :gpg_key_id, :number, :desc => "ID of a gpg key that will be assigned to this repository"
  param :unprotected, :bool, :desc => "true if this repository can be published via HTTP"
  param :url, String, :desc => "the feed url of the original repository "
  def update
    @repository.update_attributes!(repository_params)
    respond_for_show(:resource => @repository)
  end

  api :DELETE, "/repositories/:id", "Destroy a custom repository"
  param :id, :identifier, :required => true
  def destroy
    trigger(::Actions::Katello::Repository::Destroy, @repository)

    respond_for_destroy
  end

  api :PUT, "/repositories/:id/enable", "Enable a Red Hat repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  def enable
    @repository.update_attributes!(:enabled => true)
    respond_for_show :resource => @repository
  end

  api :PUT, "/repositories/:id/disable", "Disable a Red Hat repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  def disable
    @repository.update_attributes!(:enabled => false)
    respond_for_show :resource => @repository
  end

  api :POST, "/repositories/sync_complete"
  desc "URL for post sync notification from pulp"
  param 'token', String, :desc => "shared secret token", :required => true
  param 'payload', Hash, :required => true do
    param 'repo_id', String, :required => true
  end
  param 'call_report', Hash, :required => true do
    param 'task_id', String, :required => true
  end
  def sync_complete
    if params[:token] != Rack::Utils.parse_query(URI(Katello.config.post_sync_url).query)['token']
      fail Errors::SecurityViolation.new(_("Token invalid during sync_complete."))
    end

    repo_id = params['payload']['repo_id']
    task_id = params['call_report']['task_id']
    task = TaskStatus.find_by_uuid(task_id)
    User.current = (task && task.user) ?  task.user : User.hidden.first

    repo    = Repository.where(:pulp_id => repo_id).first
    fail _("Couldn't find repository '%s'") % repo_id if repo.nil?
    Rails.logger.info("Sync_complete called for #{repo.name}, running after_sync.")

    repo.async(:organization => repo.environment.organization).after_sync(task_id)
    render :nothing => true
  end

  protected

  def find_product
    @product = Product.find(params[:product_id]) if params[:product_id]
  end

  def find_product_for_create
    @product = Product.find(params[:product_id])
  end

  def find_repository
    @repository = Repository.find(params[:id])
  end

  def find_gpg_key
    if params[:gpg_key_id]
      @gpg_key = GpgKey.where(:organization_id => @organization, :id => params[:gpg_key_id]).first
      fail HttpErrors::NotFound, _("Couldn't find gpg key '%s'") % params[:gpg_key_id] if @gpg_key.nil?
    end
  end

  def repository_params
    params.require(:repository).permit(:url, :gpg_key_id, :unprotected)
  end

  def error_on_rh_product
    fail HttpErrors::BadRequest, _("Red Hat products cannot be manipulated.") if @product.redhat?
  end

  def error_on_rh_repo
    fail HttpErrors::BadRequest, _("Red Hat repositories cannot be manipulated.") if @repository.redhat?
  end

  def find_organization_from_repo
    @organization = @repository.organization
  end

  def find_organization_from_product
    @organization = @product.organization
  end

end
end
