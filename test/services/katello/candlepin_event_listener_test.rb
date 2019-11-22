require 'katello_test_helper'

module Katello
  class CandlepinEventListenerTest < ActiveSupport::TestCase
    def test_status
      status = {
        processed_count: 0,
        failed_count: 0,
        running: false
      }
      Katello::CandlepinEventListener.reset_status

      assert_equal status, Katello::CandlepinEventListener.status(refresh: true)
    end

    def test_act_on_event
      event = mock
      Candlepin::EventHandler.any_instance.expects(:handle).with(event)
      Katello::CandlepinEventListener.act_on_event(event)
    end

    def test_initialize_listening_service
      SETTINGS[:katello][:qpid] = {url: 'the url', subscriptions_queue_address: 'queue name'}
      Katello::CandlepinListeningService.expects(:initialize_service)

      Katello::CandlepinEventListener.initialize_listening_service
    end
  end
end
