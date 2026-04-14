require 'katello_test_helper'

module Katello
  module Applicability
    class SchedulerTest < ActiveSupport::TestCase
      def queue
        Katello::ApplicableHostQueue
      end

      class DrainLoopTest < SchedulerTest
        test "does nothing when queue is empty" do
          queue.expects(:pop_hosts).returns([])
          ForemanTasks.expects(:async_task).never

          Katello::Applicability::Scheduler.drain_loop
        end

        test "spawns BulkGenerate" do
          queue.stubs(:pop_hosts).returns([1]).then.returns([])
          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [1])
          Katello::Applicability::Scheduler.expects(:sleep)

          Katello::Applicability::Scheduler.drain_loop
        end

        test "doesn't sleep when queue is full" do
          queue.stubs(:pop_hosts).returns([1, 2, 3]).then.returns([])
          queue.stubs(:batch_size).returns(3)
          ForemanTasks.expects(:async_task)
          Katello::Applicability::Scheduler.expects(:sleep).never

          Katello::Applicability::Scheduler.drain_loop
        end
      end

      class TriggerDrainTest < SchedulerTest
        test "spawns BulkGenerate" do
          queue.expects(:batch_size).returns(2)
          queue.expects(:queue_depth).returns(1)
          Katello::Applicability::Scheduler.expects(:bulk_generate_tasks).returns([])
          queue.expects(:pop_hosts).returns([:fake])
          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [:fake])

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "spawns scheduler task" do
          queue.expects(:batch_size).returns(2)
          queue.expects(:queue_depth).returns(3)
          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Scheduler)

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "does nothing when queue is empty" do
          queue.expects(:queue_depth).returns(0)
          ForemanTasks.expects(:async_task).never

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "spawns nothing when scheduler task is running" do
          queue.expects(:queue_depth).returns(1)
          Katello::Applicability::Scheduler.expects(:scheduler_task).returns(stub)
          ForemanTasks.expects(:async_task).never

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "spawns nothing when mutex can't be locked" do
          Katello::Applicability::Scheduler::DRAIN_MUTEX.lock

          ForemanTasks.expects(:async_task).never

          Katello::Applicability::Scheduler.trigger_drain
        ensure
          Katello::Applicability::Scheduler::DRAIN_MUTEX.unlock
        end
      end
    end
  end
end
