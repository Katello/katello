require 'katello_test_helper'

module Katello
  class Api::V2::RootControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults_api
    end

    def test_resource_list
      get :resource_list

      assert_response :success
    end
  end
end
