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
  helper ContentViewDefinitionsHelper

  before_filter :require_user
  before_filter :find_content_view_definition
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
  before_filter :find_filter
  before_filter :find_rule, :only => [:update, :edit_package, :add_package,
                                      :edit_package_group, :add_package_group,
                                      :edit_errata, :add_errata, :destroy_parameters]

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    manage_rule  = lambda { @view_definition.editable? }

    {
      :new => manage_rule,
      :create => manage_rule,

      :update => manage_rule,
      :edit_package => manage_rule,
      :add_package => manage_rule,
      :edit_package_group => manage_rule,
      :add_package_group => manage_rule,
      :edit_errata => manage_rule,
      :add_errata => manage_rule,
      :destroy_parameters => manage_rule,

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

  def update
    @rule.update_attributes!(params[:filter_rule])

    notify.success(_("Rule '%{type}' was successfully updated.") %
                   {:type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type)})

    render :nothing => true
  end

  def edit_package
    render :partial => "content_view_definitions/filters/rules/edit_package",
           :locals => {:view_definition => @view_definition, :filter => @filter, :rule => @rule,
                       :editable => @view_definition.editable?, :name => controller_display_name}
  end

  def add_package
    @rule.parameters[:units] ||= []
    @rule.parameters[:units] << {:name => params[:package]}
    @rule.save!

    notify.success(_("Package rule successfully updated for filter '%{filter}'.") % {:filter => @filter.name})

    render :partial => 'content_view_definitions/filters/rules/package_item',
           :locals => {:editable => @view_definition.editable?,
                       :unit => {:name => params[:package]}}
  end

  def edit_package_group
    # TODO
  end

  def add_package_group
    # TODO
  end

  def edit_errata
    # TODO
  end

  def add_errata
    # TODO
  end

  def destroy_parameters
    if params[:units] && @rule.parameters[:units]
      params[:units].each_pair do |key, value|
        @rule.parameters[:units].delete({"name" => key})
      end
    end
    @rule.save!

    notify.success(_("Rule parameters successfully deleted for rule type '%{type}'. Parameters deleted: %{parameters}.") %
                   {:type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                    :parameters => params[:units].keys.join(', ')})

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

  def find_rule
    @rule = FilterRule.find(params[:id])
  end

  private

  def controller_display_name
    return 'rules'
  end

end
