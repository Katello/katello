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

class FilterRulesController < ApplicationController

  helper FiltersHelper
  helper ContentViewDefinitionsHelper
  include FilterRulesHelper

  before_filter :require_user
  before_filter :find_content_view_definition
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
  before_filter :find_filter
  before_filter :find_rule, :only => [:edit, :edit_parameter_list, :edit_date_type_parameters,
                                      :update, :add_parameter, :destroy_parameters]

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    manage_rule  = lambda { @view_definition.editable? }

    {
      :new => manage_rule,
      :create => manage_rule,

      :edit => manage_rule,
      :edit_parameter_list => manage_rule,
      :edit_date_type_parameters => manage_rule,
      :update => manage_rule,

      :add_parameter => manage_rule,
      :destroy_parameters => manage_rule,

      :destroy_rules => manage_rule,
    }
  end

  def param_rules
    {
      :create => {:filter_rule => [:content_type]},
      :update => {:filter_rule => [:inclusion]}
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

  def edit
    render :partial => "content_view_definitions/filters/rules/edit",
           :locals => {:view_definition => @view_definition, :filter => @filter, :rule => @rule,
                       :editable => @view_definition.editable?, :name => controller_display_name,
                       :rule_type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                       :item_partial => item_partial(@rule)}
  end

  def edit_parameter_list
    render :partial => "content_view_definitions/filters/rules/parameter_list",
           :locals => {:view_definition => @view_definition, :filter => @filter,
                       :rule => @rule, :rule_type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                       :editable => @view_definition.editable?, :item_partial => item_partial(@rule)}
  end

  def edit_date_type_parameters
    render :partial => "content_view_definitions/filters/rules/edit_errata_parameters",
           :locals => {:view_definition => @view_definition, :filter => @filter,
                       :rule => @rule, :rule_type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                       :editable => @view_definition.editable?}
  end

  def update
    @rule.update_attributes!(params[:filter_rule])

    notify.success(_("Rule '%{type}' was successfully updated.") %
                   {:type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type)})

    render :nothing => true
  end

  def add_parameter
    if params[:parameter]
      if params[:parameter][:unit]
        @rule.parameters[:units] ||= []
        @rule.parameters[:units] << params[:parameter][:unit]

        # a parameter may not contain both units and following properties; therefore, remove them
        [:date_range, :errata_type, :severity].each{ |parameter| @rule.parameters.delete(parameter)}
        @rule.save!

        notify.success(_("%{type} rule successfully updated for filter '%{filter}'.") %
                         {:type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                          :filter => @filter.name})

        render :partial => item_partial(@rule),
               :locals => {:editable => @view_definition.editable?, :unit => params[:parameter][:unit]} and return

      else
        if params[:parameter][:date_range]
          @rule.parameters[:date_range] ||= {}
          if params[:parameter][:date_range][:start]
            result = params[:parameter][:date_range][:start]
            @rule.parameters[:date_range][:start] = result
          elsif params[:parameter][:date_range][:end]
            result = params[:parameter][:date_range][:end]
            @rule.parameters[:date_range][:end] = result
          end
        elsif params[:parameter][:errata_type]
          @rule.parameters[:errata_type] ||= []
          @rule.parameters[:errata_type] = params[:parameter][:errata_type]
          result = selected_errata_types(@rule)
        else
          result = params[:parameter].values.first
          @rule.parameters.merge!(params[:parameter])
        end

        # a parameter may not contain both units and the parameter provided; therefore, remove the units
        @rule.parameters.delete(:units)
        @rule.save!

        notify.success(_("%{type} rule successfully updated for filter '%{filter}'.") %
                           {:type => FilterRule::CONTENT_OPTIONS.index(@rule.content_type),
                            :filter => @filter.name})

        render :text => escape_html(result) and return
      end
    end
    render :nothing => true
  end

  def destroy_parameters
    if params[:units] && @rule.parameters[:units]
      key_field = @rule.content_type == FilterRule::ERRATA ? 'id' : 'name'
      params[:units].each_pair do |key, value|
        @rule.parameters[:units].delete({key_field => key})
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

  def item_partial(rule)
    case @rule.content_type
       when FilterRule::PACKAGE
         'content_view_definitions/filters/rules/package_item'
       when FilterRule::PACKAGE_GROUP
         'content_view_definitions/filters/rules/package_group_item'
       when FilterRule::ERRATA
         'content_view_definitions/filters/rules/errata_item'
     end
  end

  private

  def controller_display_name
    return 'rules'
  end

end
