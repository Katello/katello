require 'katello_test_helper'

module Actions
  module Katello
    module AgentActionTests
      extend ActiveSupport::Concern
      include Dynflow::Testing

      included do
        let(:host) { hosts(:one) }
        let(:dispatch_history) { ::Katello::Agent::DispatchHistory.create!(host_id: host.id) }

        let(:dispatch_histories) do
          {
            host.id.to_s => dispatch_history.id
          }
        end

        let(:action) do
          action = create_action action_class
          action.stubs(:action_subject).with(host)
          plan_action action, host, { content: content }
        end

        let(:dispatched_action) do
          action = create_action action_class
          action.stubs(:action_subject).with(host)
          plan_action action, host, { content: content, dispatch_histories: dispatch_histories }
        end

        let(:dispatcher_params) do
          {
            content: content
          }
        end

        def test_run
          ::Katello::Agent::Dispatcher.expects(:dispatch).with(action_class.agent_message, [host.id], dispatcher_params).returns([dispatch_history])

          run_action action

          dispatch_history.reload

          assert_equal host.id, dispatch_history.host_id
          assert dispatch_history.dynflow_execution_plan_id
          assert dispatch_history.dynflow_step_id
        end

        def test_run_already_dispatched
          ::Katello::Agent::Dispatcher.expects(:dispatch).never
          ::Katello::Agent::DispatchHistory.expects(:find_by_id).returns(dispatch_history)

          run_action dispatched_action

          assert_equal host.id, dispatch_history.host_id
          assert dispatch_history.dynflow_execution_plan_id
          assert dispatch_history.dynflow_step_id
        end

        def test_process_timeout_accept
          action.expects(:dispatch_history).returns(dispatch_history)

          error = assert_raises(StandardError) { action.process_timeout }

          assert_match(/did not respond/, error.message)
        end

        def test_process_timeout_finish
          dispatch_history.accepted_at = Time.now
          action.expects(:dispatch_history).returns(dispatch_history)

          error = assert_raises(StandardError) { action.process_timeout }

          assert_match(/did not finish/, error.message)
        end

        def test_process_timeout_noop
          dispatch_history.accepted_at = Time.now
          dispatch_history.result = { :foo => "bar" }
          action.expects(:dispatch_history).returns(dispatch_history)

          action.process_timeout
        end

        def test_humanized_output
          Actions::Katello::Agent::DispatchHistoryPresenter.any_instance.expects(:humanized_output)

          action.humanized_output
        end
      end
    end
  end
end
