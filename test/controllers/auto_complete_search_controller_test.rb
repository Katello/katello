require 'katello_test_helper'

module Katello
  class AutoCompleteSearchControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults
      login_user(User.find(users(:admin).id))
      models
      permissions
    end

    def test_auto_complete_search
      @request.env['HTTP_ACCEPT'] = 'application/json'
      Katello::Product.expects(:complete_for).returns([" name =  \"Fedora\""])

      get :auto_complete_search, :search => " name = Simpl*3", :kt_path => 'products'

      assert_response :success
    end
  end
end
