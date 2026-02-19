require 'katello_test_helper'

module Actions
  module Katello
    module Pool
      class DestroyExpiredTest < ActiveSupport::TestCase
        include Dynflow::Testing

        it 'runs' do
          action = create_action Actions::Katello::Pool::DestroyExpired
          pool = build_stubbed(:katello_pool)
          relation = mock(destroy_all: [pool])
          ::Katello::Pool.expects(:expired).returns(relation)

          run = run_action action

          assert_equal [pool.id], run.output[:removed_pool_ids]
        end
      end
    end
  end
end
