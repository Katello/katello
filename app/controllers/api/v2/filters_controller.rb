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


class Api::V2::FiltersController < Api::V1::FiltersController

  skip_before_filter :find_organization

  include Api::V2::Rendering

  api :GET, "/content_view_definitions/:content_view_definition_id/filters",
      "List filters"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  def index
    super
  end

  api :POST, "/content_view_definitions/:content_view_definition_id/filters",
      "Create a filter for a content view definition"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter, Hash, :required => true, :action_aware => true do
    param :name, String, :desc => "name of the filter", :required => true
  end
  def create
    filter = Filter.create!(:content_view_definition => @definition, :name => params[:filter][:name])
    respond :resource => filter
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/filters/:id",
      "Show filter info"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, String, :desc => "name of the filter", :required => true
  def show
    super
  end

  api :DELETE, "/content_view_definitions/:content_view_definition_id/filters/:id",
      "Delete a filter"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, String, :desc => "name of the filter", :required => true
  def destroy
    super
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/filters/:id/products",
      "List all the products for a content view definition filter"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, String, :desc => "name of the filter", :required => true
  def list_products
    super
  end

  api :PUT, "/content_view_definitions/:content_view_definition_id/filters/:id/products",
      "Update products for a content view definition filter"
  param :content_view_definition_id, :identifier, :required => true,
        :desc                                               => "content view definition identifier"
  param :id, String, :desc => "name of the filter", :required => true
  param :products, Array, :desc => "Updated list of product ids", :required => true
  def update_products
    _update_products! params
    respond_for_update :resource => @filter
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
      "List all the repositories for a content view definition filter"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, String, :desc => "name of the filter", :required => true
  def list_repositories
    super
  end

  api :PUT, "/content_view_definitions/:content_view_definition_id/filters/:id/repositories",
      "Update repositories for a content view definition filter"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :id, String, :desc => "name of the filter", :required => true
  param :repos, Array, :desc => "Updated list of repo ids", :required => true
  def update_repositories
    _update_repositories! params
    respond_for_update :resource => @filter
  end

  private

  def find_definition
    @definition   = ContentViewDefinition.find(params[:content_view_definition_id])
    @organization ||= @definition.organization
  end

end
