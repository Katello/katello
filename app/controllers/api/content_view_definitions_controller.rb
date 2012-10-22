class Api::ContentViewDefinitionsController < Api::ApiController
  respond_to :json
  before_filter :find_organization, :except => [:destroy]
  before_filter :find_definition, :except => [:index, :create]

  def rules
    view_rule = lambda { true }
    show_rule = lambda { true }
    publish_rule = lambda { true }
    index_rule = lambda { true }
    manage_rule = lambda { true }

    {
      :index => index_rule,
      :create => manage_rule,
      :publish => publish_rule,
      :show => show_rule,
      :update => manage_rule,
      :destroy => manage_rule
    }
  end

  api :GET, "/organizations/:organization_id/content_view_definitions",
    "List content view definitions"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :label, :identifier, :desc => "content view identifier"
  def index
    if (label = params[:label])
      definitions = @organization.content_view_definitions.where(:label => label)
    else
      definitions = @organization.content_view_definitions
    end

    render :json => definitions
  end

  api :POST, "/content_view_definitions",
    "Create a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :content_view_definition, Hash do
    param :name, String, :desc => "Content view definition name",
      :required => true
    param :label, String, :desc => "Content view identifier"
    param :description, String, :desc => "Definition description"
  end
  def create
    attrs = params[:content_view_definition]
    definition = ContentViewDefinition.create!(attrs) do |cvd|
      cvd.organization = @organization
    end
    render :json => definition.to_json
  end

  api :PUT, "/content_view_definitions/:id", "Update a definition"
  param :id, :number, :desc => "Definition identifer", :required => true
  param :content_view_definition, Hash do
    param :name, String, :desc => "Content view definition name"
    param :description, String, :desc => "Definition description"
  end
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
  param :name, String, :desc => "Organization name"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def publish
    content_view = @definition.publish
    render :json => content_view
  end

  api :DELETE, "/content_view_definitions/:id", "Delete a cv definition"
  param :id, :identifier, :desc => "Definition identifier", :required => true
  def destroy
    @definition.destroy
    render :json => @definition
  end

  private

    def find_definition
      @definition = ContentViewDefinition.find(params[:id])
    end

end
