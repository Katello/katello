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


class Api::V2::ContentViewDefinitionsController < Api::V1::ContentViewDefinitionsController

  skip_before_filter :find_organization, :except => [:create, :index]

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :content_view_definition do
    param :content_view_definition, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "Content view definition name", :required => true
      param :description, String, :desc => "Definition description"
    end
  end

  api :POST, "/organizations/:organization_id/content_view_definitions",
      "Create a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier"
  param_group :content_view_definition
  param :content_view_definition, Hash do
    param :label, String, :desc => "Content view identifier"
  end
  def create
    super
  end

  api :PUT, "/content_view_definitions/:id", "Update a definition"
  param :id, :number, :desc => "Definition identifier", :required => true
  param :org, String, :desc => "Organization name", :required => true
  param_group :content_view_definition
  def update
    super
  end

  api :POST, "/content_view_definitions/:id/publish",
      "Publish a content view"
  param :name, String, :desc => "Name for the new content view", :required => true
  param :label, String, :desc => "Label for the new content view", :required => false
  param :description, String, :desc => "Description for the new content view", :required => false
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def publish
    super
  end

  api :POST, "/content_view_definitions/:id/clone", "Clone a definition"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  param_group :content_view_definition
  param :content_view_definition, Hash do
    param :label, String, :desc => "Content view identifier"
  end
  def clone
    super
  end

  api :PUT, "/content_view_definitions/:content_view_definition_id/content_views",
      "Update a definition's content views"
  param :content_view_definition_id, :identifier, :desc => "Definition identifier", :required => true
  param :views, Array, :desc => "Updated list of view ids", :required => true
  def update_content_views
    _update_content_views! params
    respond_for_update :resource => @definition
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/repositories",
      "List all the repositories for a content view definition"
  param :content_view_definition_id, :identifier, :required => true, :desc => "Definition id"
  def list_repositories
    super
  end

  api :PUT, "/content_view_definitions/:content_view_definition_id/repositories",
      "Update repositories for content view definition"
  param :content_view_definition_id, :identifier, :required => true,
        :desc                                               => "content view definition identifier"
  param :repos, Array, :desc => "Updated list of repo ids", :required => true
  def update_repositories
    _update_repositories! params
    respond_for_update :resource => @definition
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/products",
      "Get products for content view definition"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, :identifier, :required => true,
        :desc                                               => "content view definition identifier"
  def list_products
    super
  end

  api :PUT, "/content_view_definitions/:content_view_definition_id/products",
      "Update products for content view definition"
  param :content_view_definition_id, :identifier, :required => true,
        :desc                                               => "content view definition identifier"
  param :products, Array, :desc => "Updated list of products", :required => true
  def update_products
    _update_products! params
    respond_for_update :resource => @definition
  end

  api :GET, "/content_view_definitions/:content_view_definition_id/products/all",
      "Get a list of products belonging to the content view definition, even if one its repositories have been" +
          " associated to this definition. Mainly used by filter api  "
  param :content_view_definition_id, :identifier, :required => true,
        :desc                                               => "content view definition identifier"
  def list_all_products
    super
  end

  private

  def find_definition
    id            = params[:id] || params[:content_view_definition_id]
    @definition   = ContentViewDefinition.find(id)
    @organization ||= @definition.organization
  end

end
