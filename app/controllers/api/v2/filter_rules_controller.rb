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


class Api::V2::FilterRulesController < Api::V1::FilterRulesController

  skip_before_filter :find_organization

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  api :POST,
      "/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules",
      "Create a filter rule for a content filter"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter_id, String, :desc => "name of the filter", :required => true
  param :rule, Hash, :required => true, :action_aware => true do
    param :rule, String, :required => true, :desc => "A specification of the rule in json format (required)."
    param :content, String, :desc => "content type of the rule", :required => true
    param :inclusion, String, :desc => "true if its an includes rule, false otherwise. Defauls to true", :required => false
  end
  def create
    @filter_rule = create_rule!(params[:rule])
    respond :resource => @filter_rule
  end

  api :DELETE,
      "/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id",
      "Delete a filter rule"
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter_id, String, :desc => "name of the filter", :required => true
  param :id, String, :desc => "Id of the filter rule", :required => true
  def destroy
    super
  end

  def find_definition
    @definition   = ContentViewDefinition.find(params[:content_view_definition_id])
    @organization ||= @definition.organization
  end

end
