require 'katello_test_helper'

module Katello
  module Events
    class DeleteHostAgentQueueTest < ActiveSupport::TestCase
      def setup
        @queue_name = 'pulp.agent.foo'
        @event = DeleteHostAgentQueue.new(1000) do |instance|
          instance.metadata = {
            queue_name: @queue_name
          }
        end
      end

      def test_run
        Katello::Agent::Dispatcher.expects(:delete_client_queue).with(queue_name: @queue_name)

        @event.run
      end
    end
  end
end
