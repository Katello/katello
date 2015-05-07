require 'katello_test_helper'

module Katello
  class ApplicationControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults
      login_user(User.find(users(:admin)))
    end

    def test_403
      get :permission_denied
      assert_response :success
      assert_template 'common/403'
    end
  end
end
