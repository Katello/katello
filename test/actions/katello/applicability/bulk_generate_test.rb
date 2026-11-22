require 'katello_test_helper'

module Actions::Katello::Applicability::Hosts
  class BulkGenerateTest < ActiveSupport::TestCase
    include Support::Actions::Fixtures

    def test_calculations_take_host_locks_in_consistent_order
      action = fixture_action(BulkGenerate, input: {host_ids: [2, 1]})
      order = sequence('host lock order')
      ::Katello::ApplicableHostQueue.expects(:with_host_lock).with(1).in_sequence(order).yields
      ::Katello::ApplicableHostQueue.expects(:with_host_lock).with(2).in_sequence(order).yields
      first = stub(present?: true)
      second = stub(present?: true)
      ::Katello::Host::ContentFacet.expects(:find_by_host_id).with(1).returns(first)
      ::Katello::Host::ContentFacet.expects(:find_by_host_id).with(2).returns(second)
      first.expects(:calculate_and_import_applicability)
      second.expects(:calculate_and_import_applicability)

      result = run_action(action)

      assert_nil result.error
      assert_equal ::Katello::HOST_TASKS_QUEUE, action.queue
    end
  end
end
