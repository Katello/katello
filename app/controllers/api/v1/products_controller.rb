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

class Api::V1::ProductsController < Api::V1::ApiController
  respond_to :json
  before_filter :find_optional_organization, :only => [:index, :repositories, :show, :update, :destroy, :set_sync_plan, :remove_sync_plan]
  before_filter :find_environment, :only => [:index, :repositories]
  before_filter :find_content_view, :only => [:repositories]
  before_filter :find_product, :only => [:repositories, :show, :update, :destroy, :set_sync_plan, :remove_sync_plan]
  before_filter :verify_presence_of_organization_or_environment, :only => [:index]
  before_filter :authorize

  def rules
    index_test = lambda { Product.any_readable?(@organization) }
    read_test = lambda { @product.readable? }
    edit_test = lambda { @product.editable? }
    repo_test = lambda { Product.any_readable?(@organization) }

    {
      :index => index_test,
      :show => read_test,
      :update => edit_test,
      :destroy => edit_test,
      :repositories => repo_test,
      :set_sync_plan => edit_test,
      :remove_sync_plan => edit_test,
    }
  end

  def param_rules
    {
        :update => {:product => [:description, :gpg_key_name, :recursive]}
    }
  end

  def_param_group :product do
    param :product, Hash, :required => true, :action_aware => true do
      param :gpg_key_name, :identifier, :desc => "identifier of the gpg key"
      param :description, String, :desc => "Product description"
    end
  end

  api :GET, "/organizations/:organization_id/products/:id", "Show a product"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "product numeric identifier"
  def show
    respond
  end

  api :PUT, "/organizations/:organization_id/products/:id", "Update a product"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "product numeric identifier"
  param_group :product
  param :product, Hash do
    param :recursive, :bool, :desc => "set to true to recursive update gpg key"
  end
  def update
    raise HttpErrors::BadRequest, _("It is not allowed to update a Red Hat product.") if @product.redhat?
    @product.update_attributes!(params[:product].slice(:description, :gpg_key_name))
    if params[:product][:recursive]
      @product.reset_repo_gpgs!
    end
    respond
  end

  api :GET, "/environments/:environment_id/products", "List products"
  api :GET, "/organizations/:organization_id/products", "List products"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :name, :identifier, :desc => "product identifier"
  def index
    query_params.delete(:organization_id)
    query_params.delete(:environment_id)

    if @environment.nil?
      products = Product.all_readable(@organization)
    else
      products = @environment.products.all_readable(@organization)
    end

    respond :collection => products.select("products.*, providers.name AS provider_name").joins(:provider).where(query_params).all
  end

  api :DELETE, "/organizations/:organization_id/products/:id", "Destroy a product"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "product numeric identifier"
  def destroy
    @product.destroy
    respond :message => _("Deleted product '%s'") % params[:id]
  end

  api :GET, "/environments/:environment_id/products/:id/repositories"
  api :GET, "/organizations/:organization_id/products/:id/repositories"
  api :GET, "/organizations/:organization_id/products/:id/repositories"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :id, :number, :desc => "product numeric identifier"
  param :include_disabled, :bool, :desc => "set to True if you want to list disabled repositories"
  param :name, :identifier, :desc => "repository identifier"
  param :content_view_id, :identifier, :desc => "find repos in content view instead of default content view"
  def repositories
    respond_for_index :collection => @product.repos(@environment, query_params[:include_disabled], @content_view).
      where(query_params.slice(:name))
  end

  api :POST, "/organizations/:organization_id/products/:id/sync_plan", "Assign sync plan to product"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "product numeric identifier"
  param :plan_id, :number, :desc => "Plan numeric identifier"
  def set_sync_plan
    @product.sync_plan = SyncPlan.find(params[:plan_id])
    @product.save!
    respond_for_status :message => _("Synchronization plan assigned.")
  end

  api :DELETE, "/organizations/:organization_id/products/:id/sync_plan", "Delete assignment sync plan and product"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "product numeric identifier"
  param :plan_id, :number, :desc => "Plan numeric identifier"
  def remove_sync_plan
    @product.sync_plan = nil
    @product.save!
    respond_for_status :message => _("Synchronization plan assigned.")
  end

  private

  def find_product
    @product = @organization.products.find_by_cp_id(params[:id].to_s)
    raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:id] if @product.nil?
  end

  def find_environment
    if params[:environment_id].nil?
      @environment = @organization.library unless @organization.nil?
      @environment = @product.organization.library unless @product.nil?
    else
      @environment = KTEnvironment.find_by_id(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    end
    @organization ||= @environment.organization if @environment
  end

  def find_content_view
    ContentViewDefinition.readable(@organization).find(params[:content_view_id]) if params[:content_view_id]
  end

  def verify_presence_of_organization_or_environment
    return if @organization || @environment
    raise HttpErrors::BadRequest, _("Either organization ID or environment ID needs to be specified")
  end

end
