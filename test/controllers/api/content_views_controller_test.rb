require "minitest_helper"

class Api::ContentViewsControllerTest < MiniTest::Rails::ActionController::TestCase
  include UserHelper

  def setup
    AppConfig.use_cp = false
    AppConfig.use_pulp = false

    @organization = FactoryGirl.create(:org)
    @content_view = FactoryGirl.create(:content_view)
  end

  def tear_down
    @organization.destroy
    @content_view.destroy
  end

  def test_index
    with_logged_in_user do |u|
      get "/api/organizations/#{@organization.name}/content_views"
      assert_response :success
      assert_equal @organization.content_views, assigns(:content_views)
    end
  end
end
