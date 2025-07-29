require 'katello_test_helper'

module ::Actions::Katello::EventQueue
  class MonitorTest < ActiveSupport::TestCase
    include Dynflow::Testing

    class ::Dynflow::Testing::DummyCoordinator
      def find_locks(_filter)
        []
      end

      def acquire(_lock)
        true
      end
    end

    let(:action_class) { ::Actions::Katello::EventQueue::Monitor }

    let(:planned_action) do
      action = create_action action_class
      plan_action action
    end

    let(:running_action) do
      Katello::EventQueue.expects(:initialize)

      run_action planned_action
    end

    def test_run
      Katello::EventMonitor::PollerThread.any_instance.expects(:drain_queue)

      progress_action_time running_action

      assert_equal :suspended, running_action.state
      assert_nil running_action.output[:last_error]
    end

    def test_run_error
      Katello::EventMonitor::PollerThread.any_instance.stubs(:drain_queue).raises(StandardError)

      progress_action_time running_action

      assert_equal :suspended, running_action.state
      assert_equal event.id, running_action.output.dig(:last_error, :handler, :event, :id)
    end
  end
end
