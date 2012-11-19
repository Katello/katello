#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class ContentViewDefinitionsController < ApplicationController

  before_filter :require_user
  before_filter :find_content_view_definition, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
  before_filter :panel_options, :only => [:index, :items]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    read_test = lambda{current_organization && ContentViewDefinition.any_readable?(current_organization)}
    manage_test = lambda{true}  # TODO: update w/ correct permissions
    {
      :index => read_test,
      :items => read_test,
      :show => read_test,

      :new => manage_test,
      :create => manage_test,

      :edit => read_test,
      :update => manage_test,

      :destroy => manage_test,

      :default_label => manage_test
    }
  end

  def param_rules
    {
      :create => {:view_definition => [:name, :label, :description]},
      :update => {:view_definition => [:name, :description]}
    }
  end

  def items
    render_panel_direct(ContentViewDefinition, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
        {:default_field => :name, :filter=>{:organization_id=>[current_organization.id]}})
  end

  def show
    render :partial=>"common/list_update", :locals=>{:item=>@view_definition, :accessor=>"id", :columns=>['name']}
  end

  def new
    render :partial => "new", :layout => "tupane_layout"
  end

  def create
    @view_definition = ContentViewDefinition.create!(params[:content_view_definition]) do |cv|
      cv.organization = current_organization
    end
    notify.success _("Content view definition '%s' was created.") % @view_definition['name']

    if search_validate(ContentViewDefinition, @view_definition.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@view_definition, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @view_definition["name"]
      render :json => { :no_match => true }
    end
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:view_definition => @view_definition,
                                                                       :editable => @view_definition.editable?,
                                                                       :name => controller_display_name}
  end

  def update
    result = params[:view_definition].nil? ? "" : params[:view_definition].values.first

    unless params[:view_definition][:description].nil?
      result = params[:view_definition][:description] = params[:view_definition][:description].gsub("\n",'')
    end

    @view_definition.update_attributes!(params[:view_definition])

    notify.success _("Content view definition '%s' was updated.") % @view_definition["name"]

    if not search_validate(ContentViewDefinition, @view_definition.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @view_definition["name"]
    end

    render :text => escape_html(result)
  end

  def destroy
    if @view_definition.destroy
      notify.success _("Content view definition '%s' was deleted.") % @view_definition[:name]
      render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
    end
  end

  protected

  def find_content_view_definition
    @view_definition = ContentViewDefinition.find(params[:id])
  end

  def panel_options
    @panel_options = { 
      :title => _('Content View Definitions'),
      :col => ['name'],
      :titles => [_('Name')],
      :create => _('Key'),
      :create_label => _('+ New View Definition'),
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_content_view_definitions_path(),
      :enable_create => ContentViewDefinition.creatable?(current_organization),
      :search_class => ContentViewDefinition}
  end

  private

  def controller_display_name
    return 'content_view_definition'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

end
