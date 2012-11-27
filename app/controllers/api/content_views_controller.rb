class Api::ContentViewsController < Api::ApiController
  respond_to :json
  before_filter :find_organization
  before_filter :find_optional_environment, :only => [:index]

  def rules
    index_test   = lambda { ContentView.any_readable?(@organization) }
    show_test    = lambda { @view.readable? }

    {
      :index   => index_test,
      :show    => show_test
    }
  end

  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :name, :identifier, :desc => "content view identifier"
  def index
    if @environment
      ContentView.non_default.readable(@organization).
        joins(:content_view_environments).
        where("content_view_environments.environment_id = ?", @environment.id)
    else
      @content_views = ContentView.non_default.readable(@organization)
    end
    if params[:name].present?
      @content_views = @content_views.select {|cv| cv.name == params[:name]}
    end
    render :json => @content_views
  end

  api :GET, "/content_views/:id"
  param :id, :identifier, :desc => "content view id"
  def show
    render :json => @view
  end

  private

  def find_content_view
    @view = ContentView.non_default.find(params[:id])
  end

end
