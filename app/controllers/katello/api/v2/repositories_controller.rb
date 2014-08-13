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
  before_filter :find_repository, :only => [:show, :update, :destroy, :sync,
                                            :remove_packages, :upload_content,
                                            :import_uploads, :gpg_key_content]
  before_filter :find_organization_from_repo, :only => [:update]
  before_filter :find_gpg_key, :only => [:create, :update]
  before_filter :error_on_rh_product, :only => [:create]
  before_filter :error_on_rh_repo, :only => [:update, :destroy]

  skip_before_filter :authorize, :only => [:sync_complete, :gpg_key_content]
  skip_before_filter :require_org, :only => [:sync_complete]
  skip_before_filter :require_user, :only => [:sync_complete]

  wrap_parameters :include => (Repository.attribute_names + ["url"])

  def_param_group :repo do
    param :name, String, :required => true
    param :label, String, :required => false
    param :product_id, :number, :required => true, :desc => N_("Product the repository belongs to")
    param :url, String, :required => true, :desc => N_("repository source url")
    param :gpg_key_id, :number, :desc => N_("id of the gpg key that will be assigned to the new repository")
    param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
    param :content_type, String, :desc => N_("type of repo (either 'yum' or 'puppet', defaults to 'yum')")
  end

  api :GET, "/repositories", N_("List of enabled repositories")
  api :GET, "/content_views/:id/repositories", N_("List of repositories for a content view")
  param :organization_id, :number, :required => true, :desc => N_("ID of an organization to show repositories in")
  param :product_id, :number, :desc => N_("ID of a product to show repositories of")
  param :environment_id, :number, :desc => N_("ID of an environment to show repositories in")
  param :content_view_id, :number, :desc => N_("ID of a content view to show repositories in")
  param :library, :bool, :desc => N_("show repositories in Library and the default content view")
  param :content_type, String, :desc => N_("limit to only repositories of this time")
  param :name, String, :desc => N_("name of the repository"), :required => false
  param_group :search, Api::V2::ApiController
  def index
    options = sort_params
    options[:load_records?] = true
    options[:filters] = []

    if @product
      options[:filters] << {:term => {:product_id => @product.id}}
    else
      ids = Repository.where(:product_id => Product.readable.where(:organization_id => @organization.id)).pluck(:id)
    end

    options[:filters] << {:terms => {:id => ids}} if ids
    options[:filters] << {:term => {:environment_id => params[:environment_id]}} if params[:environment_id]
    options[:filters] << {:term => {:content_view_ids => params[:content_view_id]}} if params[:content_view_id]
    if params[:library] || params[:environment_id].nil?
      options[:filters] << {:term => {:content_view_version_id => @organization.default_content_view.versions.first.id}}
    end
    options[:filters] << {:term => {:content_type => params[:content_type]}} if params[:content_type]
    options[:filters] << {:term => {:name => params[:name]}} if params[:name]

    respond :collection => item_search(Repository, params, options)
  end

  api :POST, "/repositories", N_("Create a custom repository")
  param_group :repo
  def create
    params[:label] = labelize_params(params)
    params[:url] = nil if params[:url].blank?
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

  api :GET, "/repositories/:id", N_("Show a custom repository")
  param :id, :identifier, :required => true, :desc => N_("repository ID")
  def show
    respond_for_show(:resource => @repository)
  end

  api :POST, "/repositories/:id/sync", N_("Sync a repository")
  param :id, :identifier, :required => true, :desc => N_("repository ID")
  def sync
    task = async_task(::Actions::Katello::Repository::Sync, @repository)
    respond_for_async :resource => task
  end

  api :PUT, "/repositories/:id", N_("Update a custom repository")
  param :name, String, :desc => N_("New name for the repository")
  param :id, :identifier, :required => true, :desc => N_("repository ID")
  param :gpg_key_id, :number, :desc => N_("ID of a gpg key that will be assigned to this repository")
  param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
  param :url, String, :desc => N_("the feed url of the original repository ")
  def update
    repo_params = repository_params
    repo_params[:url] = nil if repository_params[:url].blank?
    sync_task(::Actions::Katello::Repository::Update, @repository, repo_params)
    respond_for_show(:resource => @repository)
  end

  api :DELETE, "/repositories/:id", N_("Destroy a custom repository")
  param :id, :identifier, :required => true
  def destroy
    trigger(::Actions::Katello::Repository::Destroy, @repository)

    respond_for_destroy
  end

  api :POST, "/repositories/sync_complete"
  desc N_("URL for post sync notification from pulp")
  param 'token', String, :desc => N_("shared secret token"), :required => true
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
    render :json => {}
  end

  api :POST, "/repositories/:id/remove_packages"
  desc "Remove rpms from a repository"
  param :id, :identifier, :required => true, :desc => "repository ID"
  param 'uuids', Array, :required => true, :desc => "Array of package uuids to remove"
  def remove_packages
    fail _("No package uuids provided") if params[:uuids].blank?
    respond_for_async :resource => sync_task(::Actions::Katello::Repository::RemovePackages, @repository, params[:uuids])
  end

  api :POST, "/repositories/:id/upload_content", N_("Upload content into the repository")
  param :id, :identifier, :required => true, :desc => N_("repository ID")
  param :content, File, :required => true, :desc => N_("Content files to upload. Can be a single file or array of files.")
  def upload_content
    filepaths = Array.wrap(params[:content]).compact.map(&:path)

    if !filepaths.blank?
      @repository.upload_content(filepaths)
      render :json => {:status => "success"}
    else
      fail HttpErrors::BadRequest, _("No file uploaded")
    end

  rescue Katello::Errors::InvalidRepositoryContent => error
    respond_for_exception(
      error,
      :status => :unprocessable_entity,
      :text => error.message,
      :errors => [error.message],
      :with_logging => true
    )
  end

  api :PUT, "/repositories/:id/import_uploads", N_("Import uploads into a repository")
  param :id, :identifier, :required => true, :desc => N_("Repository id")
  param :upload_ids, Array, :required => true, :desc => N_("Array of upload ids to import")
  def import_uploads
    params[:upload_ids].each do |upload_id|
      begin
        @repository.import_upload(upload_id)
      rescue Katello::Errors::InvalidRepositoryContent => e
        raise HttpErrors::BadRequest, e.message
      end
    end

    render :nothing => true
  end

  # returns the content of a repo gpg key, used directly by yum
  # we don't want to authenticate, authorize etc, trying to distinguish between a yum request and normal api request
  # might not always be 100% bullet proof, and its more important that yum can fetch the key.
  api :GET, "/repositories/:id/gpg_key_content", N_("Return the content of a repo gpg key, used directly by yum")
  param :id, :identifier, :required => true
  def gpg_key_content
    if @repository.gpg_key && @repository.gpg_key.content.present?
      render(:text => @repository.gpg_key.content, :layout => false)
    else
      head(404)
    end
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
      @gpg_key = GpgKey.readable.where(:id => params[:gpg_key_id], :organization_id => @organization).first
      fail HttpErrors::NotFound, _("Couldn't find gpg key '%s'") % params[:gpg_key_id] if @gpg_key.nil?
    end
  end

  def repository_params
    params.require(:repository).permit(:url, :gpg_key_id, :unprotected, :name)
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
