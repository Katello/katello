require 'katello_test_helper'

module Katello
  module Events
    class DeletePoolTest < ActiveSupport::TestCase
      def setup
        @queue_name = 'pulp.agent.foo'
        @pool = katello_pools(:pool_one)
        @event = DeletePool.new(@pool.id)
      end

      def test_run
        @event.run

        assert_empty Katello::Pool.where(id: @pool.id)
      end
    end
  end
end
