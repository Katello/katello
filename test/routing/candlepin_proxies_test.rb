require 'katello_test_helper'

module Katello
  class Api::Rhsm::CandlepinProxiesControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults
      @proxies_controller = "katello/api/rhsm/candlepin_proxies"
    end

    def test_user_resource_proxies
      {:controller => @proxies_controller, :action => "list_owners", :login => "1"}.must_recognize(:method => "get", :path => "/api/rhsm/users/1/owners")
    end
  end
end
