require 'katello_test_helper'
require 'support/event_queue_support'

module Katello
  class Api::Internal::EventQueueController::TestCase < ActionController::TestCase
    include Katello::EventQueueSupport

    def setup
      setup_engine_routes
      stub_foreman_client_auth
    end

    def test_next
      Katello::Event.create!(event_type: MockEvent::EVENT_TYPE, object_id: 1)

      post :next

      assert_response :success
    end

    def test_next_empty_queue
      post :next

      assert_response :no_content
    end

    def test_heartbeat
      post :heartbeat

      assert_response :success
    end
  end
end
