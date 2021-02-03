require 'katello_test_helper'

module Katello
  module EventDaemon
    module Services
      class AgentEventReceiverTest < ActiveSupport::TestCase
        def test_run
          AgentEventReceiver.stubs(:fetch_agent_messages).returns(true)

          assert AgentEventReceiver.run
        end

        def test_close
          refute AgentEventReceiver.close
        end

        def test_status
          assert AgentEventReceiver.status
        end
      end
    end
  end
end
