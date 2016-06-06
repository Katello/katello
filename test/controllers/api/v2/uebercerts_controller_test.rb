require 'katello_test_helper'

module Katello
  class Api::V2::UebercertsControllerTest < ActionController::TestCase
    OWNER_KEY = "some_org".freeze

    def setup
      setup_controller_defaults_api
      @org = get_organization
    end

    def test_show
      get :show, :organization_id => @org.id
    end
  end
end
