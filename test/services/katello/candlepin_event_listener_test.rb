require 'katello_test_helper'

module Katello
  class CandlepinEventListenerTest < ActiveSupport::TestCase
    def test_run_close
      client = mock('client', close: true, subscribe: true)
      Katello::CandlepinEventListener.stubs(:client_factory).returns(proc { client })

      Katello::CandlepinEventListener.run

      Katello::CandlepinEventListener.close
    end

    def test_status
      status = {
        processed_count: 0,
        failed_count: 0,
        running: false,
      }
      Katello::CandlepinEventListener.reset

      assert_equal status, Katello::CandlepinEventListener.status
    end

    def test_handle_message
      message = stub(headers: {'EVENT_TYPE' => 'updated', 'EVENT_TARGET' => 'CONSUMER'}, body: 'the body')

      Katello::CandlepinEventListener::Event.expects(:new).with('consumer.updated', 'the body')
      Candlepin::EventHandler.any_instance.expects(:handle)

      Katello::CandlepinEventListener.handle_message(message)
    end
  end
end
