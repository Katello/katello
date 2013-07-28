#
# Katello Organization actions
# Copyright 2013 Red Hat, Inc.
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

module Katello
  class Api::V1::FiltersController < Api::V1::ApiController
    respond_to :json
    before_filter :find_organization
    before_filter :find_definition
    before_filter :find_filter, :except => [:index, :create]
    before_filter :authorize

    def rules
      definition_readable = lambda { @definition && @definition.readable? }
      definition_editable = lambda { @definition && @definition.editable? }

      {
          :index               => definition_readable,
          :create              => definition_editable,
          :show                => definition_readable,
          :destroy             => definition_editable,
          :list_products       => definition_readable,
          :update_products     => definition_editable,
          :list_repositories   => definition_readable,
          :update_repositories => definition_editable
      }
    end

    api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
        "List filters"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    def index
      query_params.delete(:organization_id)
      respond :collection => @definition.filters
    end

    api :POST, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters",
        "Create a filter for a content view definition"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :filter, String, :desc => "name of the filter", :required => true
    def create
      filter = Filter.create!(:content_view_definition => @definition, :name => params[:filter])
      respond :resource => filter
    end

    api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
        "Show filter info"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :id, String, :desc => "name of the filter", :required => true
    def show
      respond :resource => @filter
    end

    api :DELETE, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id",
        "Delete a filter"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :id, String, :desc => "name of the filter", :required => true
    def destroy
      @filter.destroy
      respond :resource => @filter
    end

    api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/products",
        "List all the products for a content view definition filter"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :id, String, :desc => "name of the filter", :required => true
    def list_products
      respond_for_index :collection => @filter.products
    end

    api :PUT, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/products",
        "Update products for a content view definition filter"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, :identifier, :required => true,
          :desc                                               => "content view definition identifier"
    param :id, String, :desc => "name of the filter", :required => true
    param :products, Array, :desc => "Updated list of product ids", :required => true
    def update_products
      _update_products! params
      respond_for_update :resource => @filter.products
    end

    api :GET, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
        "List all the repositories for a content view definition filter"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :id, String, :desc => "name of the filter", :required => true
    def list_repositories
      respond_for_index :collection => @filter.repositories
    end

    api :PUT, "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
        "Update repositories for a content view definition filter"
    param :organization_id, :identifier, :desc => "organization identifier", :required => true
    param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
    param :id, String, :desc => "name of the filter", :required => true
    param :repos, Array, :desc => "Updated list of repo ids", :required => true
    def update_repositories
      _update_repositories! params
      respond_for_index :collection => @filter.repositories
    end

    private

    def find_definition
      @definition = ContentViewDefinition.where(:organization_id => @organization.id).find(params[:content_view_definition_id])
    end

    def _update_repositories!(params)
      @repos               = Repository.libraries_content_readable(@organization).
          where(:id => params[:repos])
      deleted_repositories = @filter.repositories - @repos
      added_repositories   = @repos - @filter.repositories

      @filter.repositories -= deleted_repositories
      @filter.repositories += added_repositories
      @filter.save!
    end

    def find_filter
      id      = params[:id] || params[:filter_id]
      @filter = Filter.where(:content_view_definition_id => @definition).find(id)
    end

    def _update_products!(params)
      @products        = Product.readable(@organization).where(:cp_id                      => params[:products],
                                                               "providers.organization_id" => @organization.id).joins(:provider)
      deleted_products = @filter.products - @products
      added_products   = @products - @filter.products
      @filter.products -= deleted_products
      @filter.products += added_products
      @filter.save!
    end
  end
end
