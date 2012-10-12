class Api::ContentViewsController < Api::ApiController
  respond_to :json
  before_filter :find_organization

  def rules
    index_test = lambda { true }

    {
      :index => index_test
    }
  end

  api :GET, "/environments/:environment_id/content_views", "List content views"
  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier"
  param :name, :identifier, :desc => "content view identifier"
  def index
    if (@environment = KTEnvironment.find_by_id(params[:environemnt_id]))
      @content_views = @environment.content_views
    else
      @content_views = @organization.content_views
    end
    render :json => @content_views.to_json
  end

end
