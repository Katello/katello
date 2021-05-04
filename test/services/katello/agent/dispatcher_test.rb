require 'katello_test_helper'

module Katello
  module Agent
    class DispatcherTest < ActiveSupport::TestCase
      let(:host) { hosts(:one) }
      let(:consumer_id) { "pulp.agent.#{host.subscription_facet.uuid}" }
      let(:dispatch_params) { { content: ['vim'] } }
      let(:message_params) { { content: ['vim'], consumer_id: host.subscription_facet.uuid } }
      let(:agent_message) { stub('dispatch_history_id=' => 100, 'recipient_address=' => consumer_id, 'reply_to=' => 'pulp.task') }
      let(:history) { Katello::Agent::DispatchHistory.create!(host_id: host.id) }

      class TestMessage
      end

      def test_dispatch
        Katello::Agent::Dispatcher.register_message(:test, TestMessage)
        Katello::Agent::Connection.any_instance.expects(:send_messages).with([agent_message])
        TestMessage.expects(:new).with(message_params).returns(agent_message)

        Katello::Agent::Dispatcher.dispatch(:test, [history], dispatch_params)
      end

      def test_dispatch_unregistered
        assert_raises(StandardError) do
          Katello::Agent::Dispatcher.dispatch(:test, [host.id], dispatch_params)
        end
      end

      def test_create_histories
        assert_equal 0, host.dispatch_histories.length

        histories = ::Katello::Agent::Dispatcher.create_histories(host_ids: [host.id])

        assert_equal 1, histories.length

        host.reload
        assert_equal 1, host.dispatch_histories.length
      end

      def test_delete_client_queue
        Katello::Agent::Connection.any_instance.expects(:delete_client_queue).with(consumer_id)
        Katello::Agent::Dispatcher.delete_client_queue(queue_name: consumer_id)
      end
    end
  end
end
