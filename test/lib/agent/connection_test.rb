require 'katello_test_helper'

module Katello
  module Agent
    class ConnectionTest < ActiveSupport::TestCase
      let(:connection) { Katello::Agent::Connection.new }

      def test_fetch_agent_messages
        ::Katello::Qpid::Connection.any_instance.expects(:receive_messages)
        connection.fetch_agent_messages(Class)
      end

      def test_send_messages
        message = mock
        ::Katello::Qpid::Connection.any_instance.expects(:send_messages).with([message])
        connection.send_messages([message])
      end
    end
  end
end
