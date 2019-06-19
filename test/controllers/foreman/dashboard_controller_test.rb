require 'katello_test_helper'
class DashboardControllerTest < ActionController::TestCase
  def setup
    setup_controller_defaults(false, false)
    login_user(User.find(users(:admin).id))
    Dashboard::Manager.reset_user_to_default(User.current)
    models
  end

  def test_show_subscription_widget
    id = User.current.widgets.find_by(:template => 'subscription_widget').id
    get :show, params: {id: id}

    assert_response :success
  end
end
