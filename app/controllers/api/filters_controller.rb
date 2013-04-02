#
# Katello Organization actions
# Copyright (c) 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

class Api::FiltersController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_definition
  before_filter :find_filter, :except => [:index, :create]
  before_filter :authorize

  def rules
    definition_readable = lambda { @definition && @definition.readable? }
    definition_editable = lambda { @definition && @definition.editable? }

    {
      :index => definition_readable,
      :create => definition_editable,
      :show => definition_readable,
      :destroy => definition_editable,
      :list_products => definition_readable,
      :update_products => definition_editable,
      :list_repositories => definition_readable,
      :update_repositories => definition_editable
    }
  end

  api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
    "List filters"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  def index
    query_params.delete(:organization_id)
    render :json => @definition.filters
  end

  api :POST, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
    "Create a filter for a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter, String, :desc => "name of the filter", :required => true
  def create
    filter = Filter.create!(:content_view_definition => @definition, :name => params[:filter])
    render :json => filter
  end


  api :GET,  "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
      "Show filter info"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def show
    render :json => @filter
  end

  api :DELETE, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
   "Delete a filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def destroy
    @filter.destroy
    render :json => @filter
  end

  api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/products",
      "List all the products for a content view definition filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def list_products
    render :json => @filter.products
  end

  api :PUT, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/products",
      "Update products for a content view definition filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, :identifier, :required => true,
        :desc => "content view definition identifier"
  param :id, :String, :desc => "name of the filter", :required => true
  param :repos, Array, :desc => "Updated list of repo ids", :required => true
  def update_products
    @products = Product.readable(@organization).where(:cp_id => params[:products],
                              "providers.organization_id" => @organization.id).joins(:provider)
    deleted_products = @filter.products - @products
    added_products = @products - @filter.products
    @filter.products -= deleted_products
    @filter.products += added_products
    @filter.save!

    render :json => @filter.products
  end

  api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
      "List all the repositories for a content view definition filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  def list_repositories
    render :json => @filter.repositories
  end

  api :PUT, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
      "Update repositories for a content view definition filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, :String, :desc => "name of the filter", :required => true
  param :repos, Array, :desc => "Updated list of repo ids", :required => true
  def update_repositories
    org_id = @definition.organization.id
    @repos = Repository.libraries_content_readable(@organization).
      where(:id => params[:repos])
    deleted_repositories = @filter.repositories - @repos
    added_repositories = @repos - @filter.repositories

    @filter.repositories -= deleted_repositories
    @filter.repositories += added_repositories
    @filter.save!

    render :json => @filter.repositories
  end

  private

  def find_definition
    @definition = ContentViewDefinition.where(:organization_id => @organization.id).find(params[:content_view_definition_id])
  end

  def find_filter
    id = params[:id] || params[:filter_id]
    @filter = Filter.where(:name => id, :content_view_definition_id => @definition).first
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id] if @filter.nil?
    @filter
  end
end
