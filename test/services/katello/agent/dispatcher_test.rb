require 'katello_test_helper'

module Katello
  module Agent
    class DispatcherTest < ActiveSupport::TestCase
      let(:host) { hosts(:one) }
      let(:valid_params) { { arg1: :foo, host_id: host.id } }
      let(:agent_message) { stub('dispatch_history_id=' => 100, 'recipient_address' => 'nowhere') }

      class TestMessage
      end

      def test_dispatch
        Katello::Agent::Dispatcher.register_message(:test, TestMessage)
        Katello::Agent::Connection.any_instance.expects(:send_message)
        TestMessage.expects(:new).with(valid_params).returns(agent_message)

        Katello::Agent::Dispatcher.dispatch(:test, valid_params)
      end

      def test_dispatch_unregistered
        assert_raises(StandardError) do
          Katello::Agent::Dispatcher.dispatch(:test, valid_params)
        end
      end
    end
  end
end
