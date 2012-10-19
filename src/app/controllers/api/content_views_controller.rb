class Api::ContentViewsController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_content_view, :except => [:index, :create]

  def rules
    index_test   = lambda { true }
    create_test  = lambda { true }
    show_test    = lambda { true }
    update_test  = lambda { true }
    destroy_test = lambda { true }

    {
      :index   => index_test,
      :create  => create_test,
      :update  => update_test,
      :show    => show_test,
      :destroy => destroy_test
    }
  end

  api :GET, "/environments/:environment_id/content_views", "List content views"
  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :name, :identifier, :desc => "content view identifier"
  def index
    if (@environment = KTEnvironment.find_by_id(params[:environment_id]))
      @content_views = @environment.content_views
    else
      @content_views = @organization.content_views
    end
    unless params[:name].blank?
      @content_views = @content_views.where(:name => params[:name])
    end
    render :json => @content_views
  end

  api :POST, "/content_views"
  api :POST, "/organizations/%s/content_views"
  param :organization_id, :identifier, :required => true
  param :content_view, Hash, :required => true do
    param :name, String, :desc => "Content view name", :required => true
    param :description, String, :desc => "Content view description"
  end
  def create
    @content_view = ContentView.new(params[:content_view]) do |view|
      view.organization = @organization
    end
    @content_view.save!
    render :json => @content_view
  end

  def show
    render :json => @content_view
  end

  def update
    @content_view.update_attributes!(params[:content_view])
    render :json => @content_view
  end

  def destroy
    render :json => @content_view
  end

  private

    def find_content_view
      @content_view = ContentView.find_by_name(params[:id])
      raise HttpErrors::NotFound, _("Couldn't find content view '%s'") % params[:id] if @content_view.nil?
    end

end
