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

  helper ProductsHelper

  before_filter :require_user
  before_filter :find_content_view_definition, :only => [:clone, :show, :edit, :update, :destroy, :views, :content,
                                                         :update_content, :filter, :publish_setup, :publish, :status]
  before_filter :find_content_view, :only => [:refresh]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
  before_filter :panel_options, :only => [:index, :items]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    index_rule   = lambda { ContentViewDefinition.any_readable?(current_organization) }
    show_rule    = lambda { @view_definition.readable? }
    manage_rule  = lambda { @view_definition.editable? }
    publish_rule = lambda { @view_definition.publishable? }
    refresh_rule = lambda { @view.content_view_definition.publishable? }
    create_rule  = lambda { ContentViewDefinition.creatable?(current_organization) }

    {
      :index => index_rule,
      :items => index_rule,
      :show => show_rule,

      :new => create_rule,
      :create => create_rule,
      :clone => create_rule,

      :edit => show_rule,
      :update => manage_rule,

      :publish_setup => publish_rule,
      :publish => publish_rule,

      :destroy => manage_rule,

      :views => show_rule,
      :refresh => refresh_rule,
      :status => publish_rule,

      :content => show_rule,
      :update_content => manage_rule,
      :filter => show_rule,

      :default_label => manage_rule
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
      render :partial=>"common/list_item", :locals=>{:item=>@view_definition, :initial_action=>:views, :accessor=>"id",
                                                     :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @view_definition["name"]
      render :json => { :no_match => true }
    end
  end

  def clone
    new_definition = ContentViewDefinition.new
    new_definition.name = params[:name]
    new_definition.description = params[:description]
    new_definition.organization = @view_definition.organization
    new_definition.products = @view_definition.products
    new_definition.repositories = @view_definition.repositories
    new_definition.save!

    notify.success(_("Content view definition '%{new_definition_name}' created successfully as a clone of '%{definition_name}'.") %
                       {:new_definition_name => new_definition.name, :definition_name => @view_definition.name})

    render :partial => "common/list_item", :locals  => { :item => new_definition, :initial_action => :views,
                                                         :accessor => "id", :columns => ["name"],
                                                         :name => controller_display_name }
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

  def publish_setup
    # retrieve the form to enable the user to request a publish
    render :partial => "publish", :layout => "tupane_layout",
           :locals => {:view_definition => @view_definition, :editable=>@view_definition.editable?,
                       :name=>controller_display_name}
  end

  def publish
    # perform the publish
    view = @view_definition.publish(params[:content_view][:name], params[:content_view][:description],
                                    params[:content_view][:label], {:notify => true}) if params.has_key?(:content_view)

    notify.success(_("Started publish of content view '%{view_name}' from definition '%{definition_name}'.") %
                       {:view_name => params[:content_view][:name], :definition_name => @view_definition.name})

    render :nothing => true

  rescue => e
    notify.exception(_("Failed to publish content view '%{view_name}' from definition '%{definition_name}'.") %
                         {:view_name => params[:content_view][:name], :definition_name => @view_definition.name}, e)

    render :text => e.to_s, :status => 500
  end

  def views
    render :partial => "content_view_definitions/views/index", :layout => "tupane_layout",
           :locals => {:view_definition => @view_definition, :editable => @view_definition.editable?,
                       :name => controller_display_name}
  end

  def refresh
    new_version = @view.refresh_view({:notify => true})

    notify.success(_("Started refresh of content view '%{view_name}' to version %{view_version}.") %
                       {:view_name => @view.name, :view_version => new_version.version})

    render :partial => 'content_view_definitions/views/view',
           :locals => { :view_definition => @view.content_view_definition, :view => @view,
                        :task => new_version.task_status }
  rescue => e
    version = new_version.nil? ? nil : new_version.version
    notify.exception(_("Failed to refresh content view '%{view_name}' to version %{view_version}.") %
                         {:view_name => @view.name, :view_version => version}, e)

    render :text => e.to_s, :status => 500
  end

  def status
    # retrieve the status for the tasks (refresh) initiated by the client
    statuses = {:publish_status => [], :refresh_status => []}

    TaskStatus.where(:id => params[:publish_task_id]).collect do |status|
      statuses[:publish_status] << {
          :id => status.id,
          :pending? => status.pending?,
          :status_html => render_to_string(:template => 'content_view_definitions/views/_view.html.haml',
                                           :layout => false,
                                           :locals => {:view_definition => @view_definition,
                                                       :view => status.task_owner.content_view,
                                                       :task => status})
      }
    end

    TaskStatus.where(:id => params[:refresh_task_id]).collect do |status|
      statuses[:refresh_status] << {
          :id => status.id,
          :pending? => status.pending?,
          :status_html => render_to_string(:template => 'content_view_definitions/views/_version.html.haml',
                                           :layout => false, :locals => {:version => status.task_owner,
                                                                         :task => status})
      }
    end

    render :json => statuses
  end

  def content
    render :partial => "content", :layout => "tupane_layout",
           :locals => {:view_definition => @view_definition, :editable=>@view_definition.editable?,
                       :name=>controller_display_name}
  end

  def update_content
    if params[:products]
      products_ids = params[:products].empty? ? [] : Product.readable(current_organization).
          where(:id => params[:products]).pluck(:id)

      @view_definition.product_ids = products_ids
    end

    if params[:repos]
      repo_ids = params[:repos].empty? ? [] : Repository.libraries_content_readable(current_organization).
          where(:id => params[:repos].values.flatten).pluck(:id)

      @view_definition.repository_ids = repo_ids
    end

    @view_definition.save!

    notify.success _("Successfully updated content for content view definition '%s'.") % @view_definition.name
    render :nothing => true
  end

  def filter
    render :partial => "filter", :layout => "tupane_layout",
           :locals => {:view_definition => @view_definition, :editable => @view_definition.editable?,
                       :name => controller_display_name}
  end

  protected

  def find_content_view_definition
    @view_definition = ContentViewDefinition.find(params[:id])
  end

  def find_content_view
    @view = ContentView.find(params[:id])
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
      :initial_action => :views,
      :search_class => ContentViewDefinition}
  end

  private

  def controller_display_name
    return 'content_view_definition'
  end

  def search_filter
    @view_definition = {:organization_id => current_organization}
  end
end
