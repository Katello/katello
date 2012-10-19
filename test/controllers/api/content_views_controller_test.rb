require "minitest_helper"

class Api::ContentViewsControllerTest < MiniTest::Rails::ActionController::TestCase

  def setup
    services = ['Candlepin', 'Pulp', 'ElasticSearch']
    models = ['User', 'Organization', 'KTEnvironment']
    disable_glue_layers(services, models)

    @organization = FactoryGirl.create(:org)
    @content_view = FactoryGirl.create(:content_view,
                                       :organization => @organization)
    @admin = FactoryGirl.build(:admin)
    @password = @admin.password
    @admin.save!
  end

  def tear_down
    @organization.destroy
    @content_view.destroy
    Warden.test_reset!
  end

  def test_index
    login_as @admin, :scope => :api
    get :index, :organization_id => @organization.name
    assert_response :success
    assert_equal @organization.content_views, assigns(:content_views)
  end
end
