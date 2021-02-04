require 'katello_test_helper'

module Katello
  module EventDaemon
    module Services
      class AgentEventReceiverTest < ActiveSupport::TestCase
        def test_run
          Thread.expects(:new)

          AgentEventReceiver.run
        end

        def test_close
          AgentEventReceiver.close
        end

        def test_status
          AgentEventReceiver.status
        end
      end
    end
  end
end
