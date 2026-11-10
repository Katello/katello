require 'katello_test_helper'

module Katello
  class ApplicableHostQueueTest < ActiveSupport::TestCase
    self.use_transactional_tests = false
    self.pre_loaded_fixtures = false

    def setup
      HostQueueElement.delete_all
      ApplicableHostQueue.stubs(:batch_size).returns(3)
    end

    def teardown
      HostQueueElement.delete_all
    end

    def dispatch
      batches = []
      ApplicableHostQueue.dispatch_batches { |ids| batches << ids }
      batches
    end

    def test_empty_queue
      assert_empty dispatch
    end

    def test_batches_across_separate_uploads
      5.times { |host_id| ApplicableHostQueue.push_hosts([host_id]) }

      assert_equal [[0, 1, 2], [3, 4]], dispatch
      assert_equal 0, ApplicableHostQueue.queue_depth
    end

    def test_deduplicates_across_requests
      5.times { ApplicableHostQueue.push_hosts([1, 2]) }

      assert_equal [[1, 2]], dispatch
      assert_equal 0, ApplicableHostQueue.queue_depth
    end

    def test_failed_handoff_keeps_the_batch
      ApplicableHostQueue.push_hosts([1, 2])

      assert_raises(RuntimeError) do
        ApplicableHostQueue.dispatch_batches { fail 'Task persistence unavailable' }
      end

      assert_equal 2, ApplicableHostQueue.queue_depth
      assert_equal [[1, 2]], dispatch
    end

    def test_later_failure_does_not_discard_pending_work
      ApplicableHostQueue.push_hosts([1, 2, 3, 4])

      assert_raises(RuntimeError) do
        ApplicableHostQueue.dispatch_batches do |ids|
          fail 'Task persistence unavailable' if ids.include?(4)
        end
      end

      assert_equal [4], dispatch.flatten
    end

    def test_upload_during_handoff_survives_acknowledgement
      ApplicableHostQueue.push_hosts([1])

      ApplicableHostQueue.dispatch_batches do |ids|
        assert_equal [1], ids
        ApplicableHostQueue.push_hosts([1, 2])
      end

      assert_equal 2, ApplicableHostQueue.queue_depth
      assert_equal [[1, 2]], dispatch
    end

    def test_busy_dispatcher_leaves_work_queued
      ApplicableHostQueue.push_hosts([1])
      HostQueueElement.connection.expects(:select_value)
                      .with("SELECT pg_try_advisory_lock(#{ApplicableHostQueue::DISPATCH_LOCK})")
                      .returns(false)

      ApplicableHostQueue.dispatch_batches { flunk 'Another dispatcher owns the queue' }

      assert_equal 1, ApplicableHostQueue.queue_depth
    end

    def test_host_calculations_use_a_separate_lock
      HostQueueElement.connection.expects(:select_value)
                      .with("SELECT pg_advisory_xact_lock(#{ApplicableHostQueue::HOST_LOCK}, 42)")

      assert_equal :calculated, ApplicableHostQueue.with_host_lock(42) { :calculated }
    end

    def test_handoff_runs_outside_a_transaction
      ApplicableHostQueue.push_hosts([1])

      ApplicableHostQueue.dispatch_batches do |ids|
        assert_equal [1], ids
        refute HostQueueElement.connection.transaction_open?
        assert_equal 1, ApplicableHostQueue.queue_depth
      end
    end

    def test_rejects_a_caller_owned_transaction
      ApplicableHostQueue.push_hosts([1])

      HostQueueElement.transaction do
        assert_raises(RuntimeError) do
          ApplicableHostQueue.dispatch_batches { flunk 'Task would be published before commit' }
        end
      end

      assert_equal [[1]], dispatch
    end
  end
end
