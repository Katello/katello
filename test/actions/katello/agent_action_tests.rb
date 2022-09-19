require 'katello_test_helper'

module Actions
  module Katello
    module AgentActionTests
      extend ActiveSupport::Concern
      include Dynflow::Testing

      included do
        let(:host) { hosts(:one) }
        let(:dispatch_history) { ::Katello::Agent::DispatchHistory.find(action.input[:dispatch_history_id]) }
        let(:dispatched_history) { ::Katello::Agent::Dispatcher.create_histories(host_ids: [host.id]).first }
        let(:dispatch_histories) do
          {
            host.id.to_s => dispatched_history.id
          }
        end

        let(:action) do
          action = create_action action_class
          action.stubs(:action_subject).with(host, hostname: host.name, content: content)
          plan_action action, host, { content: content }
        end

        let(:bulk_action) do
          action = create_action action_class
          action.stubs(:action_subject).with(host, hostname: host.name, content: content)
          plan_action action, host, { content: content, dispatch_histories: dispatch_histories, bulk: true }
        end

        let(:dispatcher_params) do
          {
            content: content
          }
        end

        def test_run
          ::Katello::Agent::Dispatcher.expects(:dispatch).once

          run_action action

          dispatch_history.reload

          assert_equal host.id, dispatch_history.host_id
          assert dispatch_history.dynflow_execution_plan_id
          assert dispatch_history.dynflow_step_id
        end

        def test_run_bulk
          ::Katello::Agent::Dispatcher.expects(:dispatch).never

          run_action bulk_action
          dispatched_history.reload

          assert_equal host.id, dispatched_history.host_id
          assert dispatched_history.dynflow_execution_plan_id
          assert dispatched_history.dynflow_step_id
        end

        def test_process_timeout_accept
          bulk_action.expects(:dispatch_history).returns(dispatch_history)

          error = assert_raises(StandardError) { bulk_action.process_timeout }

          assert_match(/did not respond/, error.message)
        end

        def test_process_timeout_finish_elapsed
          dispatch_history.accepted_at = Time.now
          bulk_action.expects(:dispatch_history).returns(dispatch_history)

          travel_to 2.hours.from_now do
            error = assert_raises(StandardError) { bulk_action.process_timeout }
            assert_match(/did not finish/, error.message)
          end
        end

        def test_process_timeout_finish_not_elapsed
          dispatch_history.accepted_at = Time.now
          dispatch_history.result = nil
          bulk_action_run = run_action(bulk_action)
          travel_to 1.minute.from_now do
            assert_equal bulk_action_run.phase, Dynflow::Action::Run
          end
          travel_to 2.hours.from_now do
            error = assert_raises(StandardError) { bulk_action_run.process_timeout }
            assert_match(/Host did not respond within/, error.message)
          end
        end

        def test_process_timeout_noop
          dispatch_history.accepted_at = Time.now
          dispatch_history.result = { :foo => "bar" }
          bulk_action.expects(:dispatch_history).returns(dispatch_history)

          bulk_action.process_timeout
        end

        def test_humanized_output
          Actions::Katello::Agent::DispatchHistoryPresenter.any_instance.expects(:humanized_output)

          bulk_action.humanized_output
        end
      end
    end
  end
end
