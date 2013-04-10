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

class Api::ContentViewDefinitionsController < Api::ApiController
  respond_to :json
  before_filter :find_definition, :except => [:index, :create]
  before_filter :find_organization, :except => [:destroy, :update,
                                                :content_views, :update_content_views]
  before_filter :find_optional_environment, :only => [:index]
  before_filter :authorize

  def rules
    index_rule   = lambda { ContentViewDefinition.any_readable?(@organization) }
    show_rule    = lambda { @definition.readable? }
    manage_rule  = lambda { @definition.editable? }
    publish_rule = lambda { @definition.publishable? }
    create_rule  = lambda { ContentViewDefinition.creatable?(@organization) }
    clone_rule   = lambda do
      ContentViewDefinition.creatable?(@organization) && @definition.readable?
    end

    {
      :index => index_rule,
      :create => create_rule,
      :publish => publish_rule,
      :show => show_rule,
      :clone => clone_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :content_views => show_rule,
      :update_content_views => manage_rule
    }
  end

  def param_rules
    {
      :create => { :content_view_definition => [:name, :description, :label] },
      :update => { :content_view_definition => [:name, :description] }
    }
  end

  def_param_group :content_view_definition do
    param :content_view_definition, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "Content view definition name", :required => true
      param :description, String, :desc => "Definition description"
    end
  end

  api :GET, "/organizations/:organization_id/content_view_definitions",
    "List content view definitions"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :label, String, :desc => "content view label"
  param :name, String, :desc => "content view name"
  param :id, :identifier, :desc => "content view id"
  def index
    query_params.delete(:organization_id)
    @definitions = ContentViewDefinition.where(query_params).readable(@organization)

    render :json => @definitions
  end

  api :POST, "/content_view_definitions",
    "Create a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier"
  param_group :content_view_definition
  param :content_view_definition, Hash do
    param :label, String, :desc => "Content view identifier"
  end
  def create
    attrs = params[:content_view_definition]
    definition = ContentViewDefinition.create!(attrs) do |cvd|
      cvd.organization = @organization
    end
    render :json => definition.to_json
  end

  api :PUT, "/organizations/:org/content_view_definitions/:id", "Update a definition"
  param :id, :number, :desc => "Definition identifer", :required => true
  param :org, String, :desc => "Organization name", :required => true
  param_group :content_view_definition
  def update
    @definition.update_attributes!(params[:content_view_definition])
    render :json => @definition.to_json
  end

  api :GET, "/content_view_definitions/:id", "Show definition info"
  param :id, :number, :desc => "Definition identifier", :required => true
  def show
    render :json => @definition.to_json
  end

  api :POST, "/organizations/:name/content_view_definitions/:id/publish",
    "Publish a content view"
  param :name, String, :desc => "Name for the new content view", :required=>true
  param :label, String, :desc=>"Label for the new content view", :required=>false
  param :description, String, :desc=>"Description for the new content view", :required=>false
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def publish
    view = @definition.publish(params[:name], params[:description], params[:label])
    task = view.content_view_versions.first.task_status
    render :json => task, :status => 202
  end

  api :DELETE, "/content_view_definitions/:id", "Delete a cv definition"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def destroy
    raise HttpErrors::BadRequest, _("Definition cannot be deleted since one of its views has already been promoted. "\
                                    "Using a changeset, please delete the views from existing environments before deleting the "\
                                    "definition.") if @definition.has_promoted_views?

    @definition.destroy
    render :json => @definition
  end

  api :POST, "/organizations/:org/content_view_definitions/:id/clone", "Clone a definition"
  param :id, :identifier, :desc => "Definition identifer", :required => true
  param :org, String, :desc => "Organization name", :required => true
  param_group :content_view_definition do
    param :name, String, :desc => "New definition name", :required => true
    param :label, String, :desc => "New definition label", :required => true
    param :description, String, :desc => "New definition description"
  end
  def clone
    new_def = @definition.copy(params[:content_view_definition])
    render :json => new_def
  end

  api :GET, "/content_view_definitions/:id/content_views",
    "List a definition's content views"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def content_views
    render :json => @definition.component_content_views
  end

  api :PUT, "/content_view_definitions/:id/content_views",
    "Update a definition's content views"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  param :views, Array, :desc => "Updated list of view ids", :required => true
  def update_content_views
    org_id = @definition.organization.id
    @content_views = ContentView.where(:id => params[:views])
    deleted_content_views = @definition.component_content_views - @content_views
    added_content_views = @content_views - @definition.component_content_views

    @definition.component_content_views -= deleted_content_views
    @definition.component_content_views += added_content_views
    @definition.save!

    render :json => @definition.component_content_views
  end

  private

  def find_definition
    @definition = ContentViewDefinition.find(params[:id])
  end

end
