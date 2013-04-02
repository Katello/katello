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

class Api::RepositoriesController < Api::ApiController
  respond_to :json
  before_filter :find_repository, :only => [:show, :update, :destroy, :package_groups, :package_group_categories, :enable, :gpg_key_content]
  before_filter :find_organization, :only => [:create]
  before_filter :find_product, :only => [:create]

  before_filter :authorize
  skip_filter   :set_locale, :require_user, :thread_locals, :authorize, :only => [:gpg_key_content]

  skip_before_filter :authorize, :only=>[:sync_complete]
  skip_before_filter :require_org, :only=>[:sync_complete]
  skip_before_filter :require_user, :only => [:sync_complete]


  def rules
    edit_product_test = lambda{@product.editable?}
    read_test = lambda{@repository.product.readable?}
    edit_test = lambda{@repository.product.editable?}
    org_edit = lambda{@organization.editable?}

    {
      :create => edit_product_test,
      :show => read_test,
      :update => edit_test,
      :destroy => edit_test,
      :enable => edit_test,
      :package_groups => read_test,
      :package_group_categories => read_test
    }
  end

  def param_rules
    {
      :update => {:repository  => [:gpg_key_name]}
    }
  end

  api :POST, "/repositories", "Create a repository"
  param :name, String, :required => true
  param :organization_id, :identifier, :required => true, :desc => "id of an organization the repository will be contained in"
  param :product_id, :number, :required => true, :desc => "id of a product the repository will be contained in"
  param :url, :undef, :required => true, :desc => "repository source url"
  param :gpg_key_name, String, :desc => "name of a gpg key that will be assigned to the new repository"
  see "gpg_keys#index"
  def create
    raise HttpErrors::BadRequest, _("Repository can be only created for custom provider.") unless @product.custom?

    if params[:gpg_key_name].present?
      gpg = GpgKey.readable(@product.organization).find_by_name!(params[:gpg_key_name])
    elsif params[:gpg_key_name].nil?
      gpg = @product.gpg_key
    end
    content = @product.add_repo(labelize_params(params), params[:name], params[:url], 'yum', gpg)
    render :json => content
  end

  api :GET, "/repositories/:id", "Show a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  def show
    render :json => @repository.to_hash
  end

  api :PUT, "/repositories/:id", "Update a repository"
  param :id, :identifier, :required => true, :desc => "repository id"
  param :repository, Hash, :required => true do
    param :gpg_key_name, String, :desc => "name of a gpg key that will be assigned to the repository"
  end
  def update
    raise HttpErrors::BadRequest, _("It is not allowed to update a Red Hat repository.") if @repository.redhat?
    @repository.update_attributes!(params[:repository].slice(:gpg_key_name))
    render :json => @repository.to_hash
  end

  api :DELETE, "/repositories/:id", "Destroy a repository"
  param :id, :identifier, :required => true
  def destroy
    #
    # TODO: these should really be done as validations, but the orchestration engine currently converts them into OrchestrationExceptions
    #
    raise HttpErrors::BadRequest, _("Repositories can be deleted only in the '%s' environment.") % "Library" if not @repository.environment.library?
    raise HttpErrors::BadRequest, _("Repository cannot be deleted since it has already been promoted. Using a changeset, please delete the repository from existing environments before deleting it.") if @repository.promoted?

    @repository.destroy
    render :text => _("Deleted repository '%s'") % params[:id], :status => 200
  end

  api :POST, "/repositories/:id/enable", "Enable or disable a repository"
  param :id, :identifier, :required => true
  param :enable, :bool, :required => true, :desc => "flag that enables/disables the repository"
  def enable
    raise HttpErrors::NotFound, _("Disable/enable is not supported for custom repositories.") if not @repository.redhat?

    @repository.enabled = query_params[:enable]
    @repository.save!

    if @repository.enabled?
      render :text => _("Repository '%s' enabled.") % @repository.name, :status => 200
    else
      render :text => _("Repository '%s' disabled.") % @repository.name, :status => 200
    end
  end

  api :POST, "/repositories/:id/sync_complete"
  param :id, :identifier, :required => true
  desc <<-EOS
This function is used by pulp for post sync actions.
It is not authenticated, but does not accept requests unless
they have been sent from localhost.  Since we go through apache
HTTP_X_FORWARDED_FOR header should be set with original IP.
Pulp blocks during the execution of this call, so *DO NOT* try to
talk back to pulp within it.  Save that for the delayed job.
Pulp doesn't send correct headers."
EOS
  def sync_complete
    remote_ip = request.remote_ip
    forwarded = request.env["HTTP_X_FORWARDED_FOR"]

    if forwarded && ! ['127.0.0.1', '::1'].include?(forwarded)
      Rails.logger.error("Attempt to access sync_complete from forwarded address #{forwarded}")
      raise  Errors::SecurityViolation
    end

    User.current = User.hidden.first

    repo_id = params['payload']['repo_id']
    repo = Repository.where(:pulp_id =>repo_id).first
    raise _("Couldn't find repository '%s'") % repo.name if repo.nil?
    Rails.logger.info("Sync_complete called for #{repo.name}, running after_sync.")
    repo.async(:organization=>repo.environment.organization).after_sync(params[:task_id])
    render :text=>""
  end

  api :GET, "/repositories/:id/package_groups", "List all package groups in a repository"
  param :id, :identifier, :required => true
  def package_groups
    #translate group_id to id in search params (conflict with repo id used for routing)
    search_attrs = params.slice(:name)
    search_attrs[:id] = params[:group_id] if not params[:group_id].nil?

    render :json => @repository.package_groups(search_attrs)
  end

  api :GET, "/repositories/:id/package_group_categories", "List all package group categories in a repository"
  param :id, :identifier, :required => true
  def package_group_categories
    #translate category_id to id in search params (conflict with repo id used for routing)
    search_attrs = params.slice(:name)
    search_attrs[:id] = params[:category_id] if not params[:category_id].nil?

    render :json => @repository.package_group_categories(search_attrs)
  end

  # returns the content of a repo gpg key, used directly by yum
  # we don't want to authenticate, authorize etc, trying to distinquse between a yum request and normal api request
  # might not always be 100% bullet proof, and its more important that yum can fetch the key.
  api :GET, "/repositories/:id/gpg_key_content", "Return the content of a repo gpg key, used directly by yum"
  param :id, :identifier, :required => true
  def gpg_key_content
    if @repository.gpg_key && @repository.gpg_key.content.present?
      render(:text => @repository.gpg_key.content, :layout => false)
    else
      head(404)
    end
  end

  private

  def find_repository
    @repository = Repository.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:id] if @repository.nil?
    @repository
  end

  def find_product
    @product = @organization.products.find_by_cp_id params[:product_id]
    raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
  end
end
