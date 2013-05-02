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

class Api::V1::FilterRulesController < Api::V1::ApiController

  respond_to :json
  before_filter :find_organization
  before_filter :find_definition
  before_filter :find_filter
  before_filter :find_filter_rule, :except => [:create]
  before_filter :authorize

  def rules
    definition_editable = lambda { @definition && @definition.editable? }
    {
        :create  => definition_editable,
        :destroy => definition_editable,
    }
  end

  api :POST,
      "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules",
      "Create a filter rule for a content filter"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter_id, String, :desc => "name of the filter", :required => true
  param :rule, String, :required => true, :desc => "A specification of the rule in json format (required)."
  param :content, String, :desc => "content type of the rule", :required => true
  param :inclusion, String, :desc => "true if its an includes rule, false otherwise. Defauls to true", :required => false
  def create
    @filter_rule = create_rule!(params)
    respond :resource => @filter_rule
  end

  api :DELETE,
      "/organizations/:organization_id/content_view_definitions/:content_view_definition_id/filters/:filter_id/rules/:id",
      "Delete a filter rule"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :content_view_definition_id, String, :desc => "id of the content view definition", :required => true
  param :filter_id, String, :desc => "name of the filter", :required => true
  param :id, :String, :desc => "Id of the filter rule", :required => true
  def destroy
    @filter_rule.destroy
    respond :resource => @filter_rule
  end

  private

  def create_rule!(rule_params)
    rule         = JSON.parse(rule_params[:rule]).with_indifferent_access
    inclusion    = rule_params[:inclusion].to_s.to_bool
    content_type = rule_params[:content]
    if rule.has_key?(:date_range)
      date_range = rule[:date_range]
      date_range[:start] = date_range[:start].to_time.to_i if date_range.has_key?(:start)
      date_range[:end] = date_range[:end].to_time.to_i if date_range.has_key?(:end)
    end
    FilterRule.create_for(content_type, :filter => @filter, :inclusion => inclusion, :parameters => rule)
  end

  def find_definition
    @definition = ContentViewDefinition.where(:organization_id => @organization.id).find(params[:content_view_definition_id])
  end

  def find_filter
    id      = params[:filter_id]
    @filter = Filter.where(:id => id, :content_view_definition_id => @definition).first
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id] if @filter.nil?
    @filter
  end

  def find_filter_rule
    id           = params[:id]
    @filter_rule = FilterRule.where(:filter_id => @filter.id, :id => id).first
    raise HttpErrors::NotFound, _("Couldn't find filter rule '%s'") % params[:id] if @filter_rule.nil?
    @filter_rule
  end

end
