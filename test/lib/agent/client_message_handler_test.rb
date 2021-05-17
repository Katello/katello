require 'katello_test_helper'

module Katello
  module Agent
    class ClientMessageHandlerTest < ActiveSupport::TestCase
      def setup
        @host = hosts(:one)
        @details = {
          "rpm" => {

          }
        }
      end

      def test_handle_no_dispatch_history
        assert_raises(StandardError) do
          ClientMessageHandler.new(stub(body: {}.to_json))
        end
      end

      def test_handle_accepted
        dispatch_history = Katello::Agent::DispatchHistory.create!(
          host_id: @host.id,
          dynflow_execution_plan_id: SecureRandom.uuid,
          dynflow_step_id: 2
        )

        task = mock(result: 'pending')
        ForemanTasks::Task.expects(:find_by_external_id).with(dispatch_history.dynflow_execution_plan_id).returns(task)
        mock_world = mock('mock world', event: true)
        mock_dynflow = stub('mock dynflow', world: mock_world, 'world=' => mock_world)
        ForemanTasks.stubs(:dynflow).returns(mock_dynflow)

        content = {
          data: {
            dispatch_history_id: dispatch_history.id
          },
          status: 'accepted'
        }

        message = stub(body: content.to_json)
        ClientMessageHandler.new(message).handle
        dispatch_history.reload

        assert_empty dispatch_history.result
        assert dispatch_history.accepted_at
      end

      def test_handle_finished
        dispatch_history = Katello::Agent::DispatchHistory.create!(
          host_id: @host.id,
          dynflow_execution_plan_id: SecureRandom.uuid,
          dynflow_step_id: 2
        )

        task = mock(result: 'pending')
        ForemanTasks::Task.expects(:find_by_external_id).with(dispatch_history.dynflow_execution_plan_id).returns(task)
        mock_world = mock('mock world', event: true)
        mock_dynflow = stub('mock dynflow', world: mock_world, 'world=' => mock_world)
        ForemanTasks.stubs(:dynflow).returns(mock_dynflow)

        content = {
          data: {
            dispatch_history_id: dispatch_history.id
          },
          result: {
            retval: {
              details: @details
            }
          }
        }

        message = stub(body: content.to_json)
        ClientMessageHandler.new(message).handle
        dispatch_history.reload

        refute dispatch_history.accepted_at
        assert_equal @details, dispatch_history.result
      end

      def test_handle_no_dynflow_attributes
        dispatch_history = Katello::Agent::DispatchHistory.create!(
          host_id: @host.id
        )

        ForemanTasks::Task.expects(:exists?).never

        content = {
          data: {
            dispatch_history_id: dispatch_history.id
          },
          result: {
            retval: {
              details: @details
            }
          }
        }

        message = stub(body: content.to_json)
        ClientMessageHandler.new(message).handle
        dispatch_history.reload

        refute dispatch_history.accepted_at
        assert_equal @details, dispatch_history.result
      end
    end
  end
end
