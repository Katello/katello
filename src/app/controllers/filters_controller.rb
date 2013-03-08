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

class FiltersController < ApplicationController

  helper ContentViewDefinitionsHelper

  before_filter :require_user
  before_filter :find_content_view_definition, :only => [:index, :new, :create, :destroy_filters]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    index_rule   = lambda { ContentViewDefinition.any_readable?(current_organization) }
    show_rule    = lambda { @view_definition.readable? }
    manage_rule  = lambda { @view_definition.editable? }

    {
      :index => index_rule,
      :show => show_rule,

      :new => manage_rule,
      :create => manage_rule,

      :edit => show_rule,
      :update => manage_rule,

      :destroy_filters => manage_rule,
    }
  end

  def param_rules
    {
      :create => {:view_definition => [:name, :label, :description]},
      :update => {:view_definition => [:name, :description]},
    }
  end

  def index
    render :partial => "content_view_definitions/filters/index",
           :locals => {:view_definition => @view_definition, :editable => @view_definition.editable?}

  end

  def new
    render :partial => "content_view_definitions/filters/new", :locals => {:view_definition => @view_definition}
  end

  def create
    Filter.create!(params[:filter]) do |filter|
      filter.content_view_definition = @view_definition
    end

    notify.success(_("Filter '%{filter}' successfully created for content view definition '%{definition}'.") %
                    {:filter => params[:filter][:name], :definition => @view_definition.name})

    render :nothing => true
  end

  def edit
    render :partial => "edit", :locals => {:view_definition => @view_definition,
                                           :editable => @view_definition.editable?,
                                           :name => controller_display_name}
  end

  def destroy_filters
    Filter.destroy(params[:filters].keys) unless params[:filters].blank?

    notify.success(_("Filters successfully deleted for content view definition '%{definition}'. Filters deleted: %{filter_names}.") %
                   {:definition => @view_definition.name, :filter_names => params[:filters].values.join(', ')})

    render :nothing => true
  end

  protected

  def find_content_view_definition
    @view_definition = ContentViewDefinition.find(params[:content_view_definition_id])
  end

  private

  def controller_display_name
    return 'filter'
  end

end
