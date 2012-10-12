class Api::ContentViewDefinitionsController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_definition, :only => [:show, :update, :destroy]

  def rules
    view_rule = lambda { true }
    manage_rule = lambda { true }

    {
      :index => view_rule,
      :create => manage_rule
    }
  end

  api :GET, "/organizations/:organization_id/content_view_definitions",
    "List content view definitions"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :name, :identifier, :desc => "content view identifier"
  def index
    definitions = @organization.content_view_definitions
    render :json => definitions.to_json
  end

  api :POST, "/content_view_definitions",
    "Create a content view definition"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :content_view_definition, Hash do
    param :name, String, :desc => "Content view definition name",
      :required => true
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
    param :name, String, :desc => "Content view definition name",
      :required => true
    param :description, String, :desc => "Definition description"
  end
  def update
    @definition.update_attributes!(params[:content_view_definition])
    render :json => @definition.to_json
  end

  private

    def find_definition
      @definition = ContentViewDefinition.find(params[:id])
    end

end
