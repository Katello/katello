require 'katello_test_helper'

module Katello
  module Agent
    class DispatcherTest < ActiveSupport::TestCase
      let(:host) { hosts(:one) }
      let(:consumer_id) { "pulp.agent.#{host.content_facet.uuid}" }
      let(:valid_params) { { arg1: :foo, host_id: host.id } }
      let(:agent_message) { stub('dispatch_history_id=' => 100, 'recipient_address=' => consumer_id, 'reply_to=' => 'pulp.task') }

      class TestMessage
      end

      def test_dispatch
        Katello::Agent::Dispatcher.register_message(:test, TestMessage)
        Katello::Agent::Connection.any_instance.expects(:send_messages)
        TestMessage.expects(:new).with(valid_params).returns(agent_message)

        Katello::Agent::Dispatcher.dispatch(:test, [host.id], valid_params)
      end

      def test_dispatch_unregistered
        assert_raises(StandardError) do
          Katello::Agent::Dispatcher.dispatch(:test, [host.id], valid_params)
        end
      end
    end
  end
end
