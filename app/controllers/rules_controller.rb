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

class RulesController < ApplicationController

  helper FiltersHelper

  before_filter :require_user
  before_filter :find_content_view_definition, :only => [:new, :create, :destroy_rules]
  before_filter :find_filter, :only => [:new, :create, :destroy_rules]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    manage_rule  = lambda { @view_definition.editable? }

    {
      :new => manage_rule,
      :create => manage_rule,

      :destroy_rules => manage_rule,
    }
  end

  def param_rules
    {
      :create => {:filter_rule => [:content_type]}
    }
  end

  def new
    render :partial => "content_view_definitions/filters/rules/new",
           :locals => {:view_definition => @view_definition, :filter => @filter}
  end

  def create
    FilterRule.create!(params[:filter_rule]) do |rule|
      rule.filter = @filter
    end

    notify.success(_("'%{type}' rule successfully created for filter '%{filter}'.") %
                   {:type => params[:filter_rule][:content_type], :filter => @filter.name})

    render :nothing => true
  end

  def destroy_rules
    FilterRule.destroy(params[:filter_rules].keys) unless params[:filter_rules].blank?

    notify.success(_("Rules successfully deleted for filter '%{filter}'. Rules types deleted: %{types}.") %
                       {:filter => @filter.name, :types => params[:filter_rules].values.join(', ')})

    render :nothing => true
  end

  protected

  def find_content_view_definition
    @view_definition = ContentViewDefinition.find(params[:content_view_definition_id])
  end

  def find_filter
    @filter = Filter.find(params[:filter_id])
  end

  private

  def controller_display_name
    return 'rules'
  end

end
