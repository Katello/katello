require 'katello_test_helper'

module Actions
  module Katello
    module AgentActionTests
      extend ActiveSupport::Concern
      include Dynflow::Testing

      included do
        let(:host) { hosts(:one) }

        let(:dispatch_history) { ::Katello::Agent::DispatchHistory.create!(host_id: host.id) }

        def test_run
          ::Katello::Agent::Dispatcher.expects(:dispatch).with(dispatcher_method, dispatcher_params).returns(dispatch_history)

          run_action action

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
