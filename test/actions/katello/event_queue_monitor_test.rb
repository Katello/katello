require 'katello_test_helper'

class Actions::Katello::EventQueueMonitorTest < ActiveSupport::TestCase
  include Dynflow::Testing

  describe 'run' do
    let(:action_class) { ::Actions::Katello::EventQueue::Monitor }
    let(:polling_class) { ::Actions::Katello::EventQueue::PollerThread }
    let(:suspended_class) { ::Actions::Katello::EventQueue::SuspendedAction }
    let(:planned_action) do
      #action_class.any_instance.expects(:singleton_lock!)
      #action_class.any_instance.expects(:holds_singleton_lock?).returns(true)
      create_and_plan_action action_class
    end

    it 'on ready should listen' do
      suspended_class.any_instance.expects(:notify_ready).once
      action_class.any_instance.stubs(:suspend).yields(nil)
      polling_class.any_instance.expects(:poll_for_events).once

      action = run_action planned_action
      action.run(action_class::Ready)
    end

    it 'should process counts' do
      action_class.any_instance.stubs(:suspend).yields(nil)

      suspended_class.any_instance.expects(:notify_ready).once

      action = run_action planned_action
      action.run(action_class::Count[5, Time.now])
      assert_equal 5, action.output[:count]
    end
  end
end
