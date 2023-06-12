require "katello_test_helper"

module Katello
  class Api::Internal::CandlepinEventsControllerTest < ActionController::TestCase
    def setup
      setup_engine_routes
      stub_foreman_client_auth
    end

    def test_handle_ok
      event = { subject: '', content: '{}' }

      post :handle, params: event

      assert_response :success
    end

    def test_heartbeat
      post :heartbeat

      assert_response :success
    end
  end
end
