require 'katello_test_helper'

module Katello
  class ApplicableHostQueueTest < ActiveSupport::TestCase
    def setup
      Setting['applicability_batch_size'] = 50

      # Prevent any test here from triggering the scheduler & draining the queue
      Katello::Applicability::Scheduler.stubs(:trigger_drain)
    end

    def test_pop_nothing
      assert_empty ApplicableHostQueue.pop_hosts
    end

    def test_pop_1_host
      ApplicableHostQueue.push_hosts([999])
      popped_hosts = ApplicableHostQueue.pop_hosts

      assert_equal [999], popped_hosts.sort
    end

    def test_pop_5_hosts
      5.times { |i| ApplicableHostQueue.push_hosts([i]) }
      popped_hosts = ApplicableHostQueue.pop_hosts

      assert_equal [0, 1, 2, 3, 4], popped_hosts.sort
    end

    def test_pop_batch_size_only
      Setting['applicability_batch_size'] = 3
      5.times { |i| ApplicableHostQueue.push_hosts([i]) }
      popped_hosts = ApplicableHostQueue.pop_hosts

      assert_equal 3, popped_hosts.size
    end

    def test_pop_duplicate_hosts
      5.times { |i| ApplicableHostQueue.push_hosts([i]) }
      5.times { |i| ApplicableHostQueue.push_hosts([i]) }
      popped_hosts = ApplicableHostQueue.pop_hosts

      assert_equal [0, 1, 2, 3, 4], popped_hosts.sort
    end

    def test_pop_hosts_yield_error
      5.times { |i| ApplicableHostQueue.push_hosts([i]) }

      assert_raises(RuntimeError) do
        ApplicableHostQueue.pop_hosts do
          fail "Elements are not to be removed from the queue!"
        end
      end

      assert_equal 5, HostQueueElement.count
    end

    def test_queue_depth
      3.times { |i| ApplicableHostQueue.push_hosts([i]) }

      assert_equal 3, ApplicableHostQueue.queue_depth
    end
  end
end
