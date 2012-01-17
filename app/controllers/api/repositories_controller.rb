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

require 'resources/pulp'

class Api::RepositoriesController < Api::ApiController
  respond_to :json
  before_filter :find_repository, :only => [:show, :update, :destroy, :package_groups, :package_group_categories, :enable, :gpg_key_content]
  before_filter :find_product, :only => [:create]
  before_filter :find_organization, :only => [:discovery]

  before_filter :authorize
  skip_filter   :set_locale, :require_user, :thread_locals, :authorize, :only => [:gpg_key_content]

  def rules
    edit_product_test = lambda{@product.editable?}
    read_test = lambda{@repository.product.readable?}
    edit_test = lambda{@repository.product.editable?}
    org_edit = lambda{@organization.editable?}
    {
      :create => edit_product_test,
      :show => read_test,
      :destroy => edit_test,
      :enable => edit_test,
      :discovery => org_edit,
      :package_groups => read_test,
      :package_group_categories => read_test,
    }
  end

  def create
    if params[:gpg_key_name].present?
      gpg = GpgKey.readable(@product.organization).find_by_name!(params[:gpg_key_name])
    elsif params[:gpg_key_name].nil?
      gpg = @product.gpg_key
    end
    content = @product.add_repo(params[:name], params[:url], 'yum', gpg)
    render :json => content
  end

  def show
    render :json => @repository.to_hash
  end

  def update
    raise HttpErrors::BadRequest, _("It is not allowed to update a Red Hat repository.") if @repository.redhat?
    @repository.update_attributes!(params[:repository].slice(:gpg_key_name))
    render :json => @repository.to_hash
  end

  def destroy
    @repository.product.delete_repo_by_id(params[:id])
    render :text => _("Deleted repository '#{params[:id]}'"), :status => 200
  end

  def enable
    raise HttpErrors::NotFound, _("Disable/enable is not supported for custom repositories.") if not @repository.redhat?

    @repository.enabled = query_params[:enable]
    @repository.save!

    if @repository.enabled?
      render :text => _("Repository '#{@repository.name}' enabled."), :status => 200
    else
      render :text => _("Repository '#{@repository.name}' disabled."), :status => 200
    end
  end

  # proxy repository discovery call to pulp, so we don't have to create an async task to keep track of async task on pulp side
  def discovery
    pulp_task = Pulp::Repository.start_discovery(params[:url], params[:type])
    task = PulpSyncStatus.using_pulp_task(pulp_task) {|t| t.organization = @organization}
    task.save!
    render :json => task
  end

  def package_groups
    #translate group_id to id in search params (conflict with repo id used for routing)
    search_attrs = params.slice(:name)
    search_attrs[:id] = params[:group_id] if not params[:group_id].nil?

    render :json => @repository.package_groups(search_attrs)
  end

  def package_group_categories
    #translate category_id to id in search params (conflict with repo id used for routing)
    search_attrs = params.slice(:name)
    search_attrs[:id] = params[:category_id] if not params[:category_id].nil?

    render :json => @repository.package_group_categories(search_attrs)
  end

  # returns the content of a repo gpg key, used directly by yum
  # we don't want to authenticate, authorize etc, trying to distinquse between a yum request and normal api request
  # might not always be 100% bullet proof, and its more important that yum can fetch the key.
  def gpg_key_content
    if @repository.gpg_key && @repository.gpg_key.content.present?
      render(:text => @gpg_key.content, :layout => false) 
    else
      head(404)
    end
  end

  def find_repository
    @repository = Repository.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:id]}'") if @repository.nil?
    @repository
  end

  def find_product
    @product = Product.find_by_cp_id params[:product_id]
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:product_id]}'") if @product.nil?
  end
end
