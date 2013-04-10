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

class ContentViewDefinitionsController < ApplicationController

  helper ProductsHelper

  before_filter :require_user
  before_filter :find_content_view_definition, :only => [:clone, :show, :edit, :update, :destroy, :views, :content,
                                                         :update_content, :update_component_views, :filter,
                                                         :publish_setup, :publish, :status]
  before_filter :find_content_view, :only => [:refresh]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
  before_filter :panel_options, :only => [:index, :items]

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    index_rule   = lambda { ContentViewDefinition.any_readable?(current_organization) }
    show_rule    = lambda { @view_definition.readable? }
    manage_rule  = lambda { @view_definition.editable? }
    delete_rule  = lambda { @view_definition.deletable? }
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

      :destroy => delete_rule,

      :views => show_rule,
      :refresh => refresh_rule,
      :status => publish_rule,

      :content => show_rule,
      :update_content => manage_rule,
      :update_component_views => manage_rule,
      :filter => show_rule,

      :default_label => create_rule
    }
  end

  def param_rules
    {
      :create => {:view_definition => [:name, :label, :description]},
      :update => {:view_definition => [:name, :description]},
      :update_content => [:id, :products, :repos]
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
    render :partial => "new",
           :locals => {:view_definitions => ContentViewDefinition.readable(current_organization).non_composite}
  end

  def create
    @view_definition = ContentViewDefinition.create!(params[:content_view_definition]) do |cv|
      cv.organization = current_organization
    end
    if @view_definition.composite? && params[:content_views]
      @views = ContentView.where(:id => params[:content_views].keys)
      @view_definition.component_content_views += @views
      @view_definition.save!
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
    new_definition = @view_definition.copy(:name => params[:name],
                                           :description => params[:description])
    notify.success(_("Content view definition '%{new_definition_name}' created successfully as a clone of '%{definition_name}'.") %
                       {:new_definition_name => new_definition.name, :definition_name => @view_definition.name})

    render :partial => "common/list_item", :locals  => { :item => new_definition, :initial_action => :views,
                                                         :accessor => "id", :columns => ["name"],
                                                         :name => controller_display_name }
  end

  def edit
    render :partial => "edit", :locals => {:view_definition => @view_definition,
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
    render :partial => "publish",
           :locals => {:view_definition => @view_definition, :editable=>@view_definition.editable?,
                       :name=>controller_display_name}
  end

  def publish
    # perform the publish
    @view_definition.publish(params[:content_view][:name], params[:content_view][:description],
                             params[:content_view][:label], {:notify => true}) if params.has_key?(:content_view)

    notify.success(_("Started publish of content view '%{view_name}' from definition '%{definition_name}'.") %
                       {:view_name => params[:content_view][:name], :definition_name => @view_definition.name})

    render :nothing => true

  rescue => e
    notify.exception(_("Failed to publish content view '%{view_name}' from definition '%{definition_name}'.") %
                         {:view_name => params[:content_view][:name], :definition_name => @view_definition.name}, e)
    log_exception(e)

    render :text => e.to_s, :status => 500
  end

  def views
    render :partial => "content_view_definitions/views/index",
           :locals => {:view_definition => @view_definition, :editable => @view_definition.editable?,
                       :name => controller_display_name}
  end

  def refresh
    initial_version = @view.version(current_organization.library).try(:version)

    new_version = @view.refresh_view({:notify => true})

    notify.success(_("Started generating version %{view_version} of content view '%{view_name}'.") %
                       {:view_name => @view.name, :view_version => new_version.version})

    render :partial => 'content_view_definitions/views/view',
           :locals => { :view_definition => @view.content_view_definition, :view => @view,
                        :task => new_version.task_status }
  rescue => e
    current_version = @view.version(current_organization.library).try(:version)

    if (current_version == initial_version)
      notify.exception(_("Failed to generate a new version of content view '%{view_name}'.") %
                           {:view_name => @view.name}, e)
    else
      notify.exception(_("Failed to generate version %{view_version} of content view '%{view_name}'.") %
                           {:view_name => @view.name, :view_version => current_version}, e)
    end

    log_exception(e)
    render :text => e.to_s, :status => 500
  end

  def status
    # retrieve the status for publish & refresh tasks initiated by the client
    statuses = {:task_statuses => []}

    TaskStatus.where(:id => params[:task_ids]).collect do |status|
      statuses[:task_statuses] << {
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
    if @view_definition.composite?

      component_views = @view_definition.component_content_views.inject({}) do |hash, view|
        hash[view.id] = view
        hash
      end

      render :partial => "composite_definition_content",
             :locals => {:view_definition => @view_definition,
                         :view_definitions => ContentViewDefinition.readable(current_organization).non_composite,
                         :views => component_views,
                         :editable=>@view_definition.editable?,
                         :name=>controller_display_name}
    else
      render :partial => "single_definition_content",
             :locals => {:view_definition => @view_definition, :editable=>@view_definition.editable?,
                         :name=>controller_display_name}
    end
  end

  def update_content
    if params[:products]
      products_ids = params[:products].empty? ? [] : Product.readable(current_organization).
          where(:id => params[:products]).pluck("products.id")

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

  def update_component_views
    if params[:content_views]
      @content_views = ContentView.where(:id => params[:content_views].keys)
      deleted_content_views = @view_definition.component_content_views - @content_views
      added_content_views = @content_views - @view_definition.component_content_views

      @view_definition.component_content_views -= deleted_content_views
      @view_definition.component_content_views += added_content_views
    else
      @view_definition.component_content_views = []
    end
    @view_definition.save!

    notify.success _("Successfully updated content for content view definition '%s'.") % @view_definition.name
    render :nothing => true
  end

  def filter
    render :partial => "filter",
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
