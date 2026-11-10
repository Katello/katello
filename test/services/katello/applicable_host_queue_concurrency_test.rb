require 'katello_test_helper'
require 'timeout'

module Katello
  class ApplicableHostQueueConcurrencyTest < ActiveSupport::TestCase
    self.use_transactional_tests = false
    self.pre_loaded_fixtures = false

    def setup
      HostQueueElement.delete_all
      ApplicableHostQueue.stubs(:batch_size).returns(50)
      @threads = []
      @release = Queue.new
    end

    def teardown
      @threads.length.times { @release << true }
      @threads.each do |thread|
        thread.join(10) || thread.kill.join
      end
      HostQueueElement.delete_all
    end

    def in_connection(&block)
      @threads << Thread.new do
        ActiveRecord::Base.connection_pool.with_connection(&block)
      end
      @threads.last
    end

    def test_competing_dispatcher_and_upload_during_handoff
      ApplicableHostQueue.push_hosts([1])
      selected = Queue.new
      first = in_connection do
        ApplicableHostQueue.dispatch_batches do |ids|
          selected << ids
          @release.pop
        end
      end
      assert_equal [1], Timeout.timeout(10) { selected.pop }

      second = in_connection do
        ApplicableHostQueue.dispatch_batches { fail 'Duplicate dispatch' }
      end
      assert second.join(10), 'Competing dispatcher must not wait on the lock'
      assert_equal 0, second.value

      # The writer uses neither the dispatcher lock nor the calculation lock.
      ApplicableHostQueue.push_hosts([1, 2])
      @release << true
      assert first.join(10), 'First dispatcher must finish its bounded tick'
      first.value

      batches = []
      ApplicableHostQueue.dispatch_batches { |ids| batches << ids }
      assert_equal [[1, 2]], batches
    end

    def test_late_commit_with_an_older_sequence_id_is_not_acknowledged
      ApplicableHostQueue.push_hosts([1])
      inserted = Queue.new
      writer = in_connection do
        HostQueueElement.transaction do
          ApplicableHostQueue.push_hosts([1])
          inserted << true
          @release.pop
        end
      end
      Timeout.timeout(10) { inserted.pop }
      ApplicableHostQueue.push_hosts([2])

      batches = []
      ApplicableHostQueue.dispatch_batches do |ids|
        batches << ids
        if batches.length == 1
          @release << true
          assert writer.join(10), 'Upload must commit while the batch is being handed off'
          writer.value
        end
      end

      assert_equal [[1, 2], [1]], batches
      assert_equal 0, ApplicableHostQueue.queue_depth
    end

    def test_host_lock_serializes_calculations_but_not_other_hosts
      entered = Queue.new
      first = in_connection do
        ApplicableHostQueue.with_host_lock(1) do
          entered << :first
          @release.pop
        end
      end
      assert_equal :first, Timeout.timeout(10) { entered.pop }

      connection_id = Queue.new
      second = in_connection do |connection|
        connection_id << connection.select_value('SELECT pg_backend_pid()')
        ApplicableHostQueue.with_host_lock(1) { entered << :second }
      end
      pid = Timeout.timeout(10) { connection_id.pop }
      Timeout.timeout(10) do
        until HostQueueElement.connection.select_value("SELECT wait_event_type = 'Lock' FROM pg_stat_activity WHERE pid = #{Integer(pid)}")
          sleep 0.01
        end
      end
      assert_empty entered, 'The same host must not be calculated concurrently'
      assert_equal :other_host, ApplicableHostQueue.with_host_lock(2) { :other_host }

      @release << true
      assert first.join(10)
      first.value
      assert second.join(10)
      second.value
      assert_equal :second, entered.pop
    end

    def test_submitted_task_is_visible_to_another_connection_before_acknowledgement
      ApplicableHostQueue.push_hosts([0])
      task = nil

      User.as_anonymous_admin do
        ApplicableHostQueue.dispatch_batches do |ids|
          task = ForemanTasks.async_task(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: ids)
          reader = in_connection { ForemanTasks::Task.exists?(id: task.id) }

          assert reader.join(10), 'A separate executor must be able to look up the task'
          assert reader.value, 'Task must be committed before queue acknowledgement'
          assert_equal 1, ApplicableHostQueue.queue_depth
        end
      end

      assert_equal 0, ApplicableHostQueue.queue_depth
    ensure
      task&.destroy!
    end

    def test_failed_handoff_releases_the_session_lock
      ApplicableHostQueue.push_hosts([1])

      assert_raises(RuntimeError) do
        ApplicableHostQueue.dispatch_batches { fail 'Task persistence unavailable' }
      end

      reader = in_connection do
        batches = []
        ApplicableHostQueue.dispatch_batches { |ids| batches << ids }
        batches
      end
      assert reader.join(10), 'Failed handoff must not leave a session lock behind'
      assert_equal [[1]], reader.value
    end

    def test_query_cache_does_not_leak_the_dispatch_lock_after_an_empty_batch
      ApplicableHostQueue.push_hosts([1])

      HostQueueElement.connection.cache do
        dispatched = ApplicableHostQueue.dispatch_batches { |_ids| }
        assert_equal 1, dispatched
      end

      # The final empty-batch check must release the lock too. Cached unlock
      # results would leave it held by the first connection indefinitely.
      ApplicableHostQueue.push_hosts([2])
      reader = in_connection do
        batches = []
        ApplicableHostQueue.dispatch_batches { |ids| batches << ids }
        batches
      end
      assert reader.join(10), 'A second connection must acquire the dispatcher lock'
      assert_equal [[2]], reader.value
    end

    def test_query_cache_does_not_skip_host_locks_in_later_transactions
      HostQueueElement.connection.cache do
        ApplicableHostQueue.with_host_lock(1) { nil }

        ApplicableHostQueue.with_host_lock(1) do
          reader = in_connection do |connection|
            HostQueueElement.transaction do
              connection.uncached do
                connection.select_value("SELECT pg_try_advisory_xact_lock(#{ApplicableHostQueue::HOST_LOCK}, 1)")
              end
            end
          end
          assert reader.join(10), 'A competing try-lock must not block'
          refute reader.value, 'The second transaction must hold a real PostgreSQL host lock'
        end
      end
    end
  end
end
