require 'katello_test_helper'

module Katello
  class EventMonitorTest < ActiveSupport::TestCase
    def test_run
      client = mock('client', close: true, running?: true, subscribe: true)
      Katello::EventMonitor.stubs(:client).returns(client)

      Katello::EventMonitor.run

      Katello::EventMonitor.close
    end

    def test_handle_message
      message = stub(headers: {'katello_event_type' => 'import_host_applicability', 'katello_object_id' => 100}, body: '')
      Katello::Events::ImportHostApplicability.any_instance.expects(:run)

      Katello::EventMonitor.handle_message(message)
    end

    def test_status
      status = {
        processed_count: 0,
        failed_count: 0,
        running: false
      }
      Katello::EventMonitor.reset

      assert_equal status, Katello::EventMonitor.status
    end
  end
end
