require 'katello_test_helper'

module Katello
  module Applicability
    class SchedulerTest < ActiveSupport::TestCase
      let(:scheduler) { Katello::Applicability::Scheduler }
      let(:queue) { @queue }

      def setup_queue(queue)
        @queue = queue
        scheduler.stubs(:queue).returns(queue)
      end

      class TestQueue
        def pop_hosts
          @ids = @queue.pop
          yield(@ids)
          @ids
        end

        def queue_depth
          @queue.flatten.length
        end
      end

      class EmptyQueue < TestQueue
        def initialize
          @queue = []
          super
        end
      end

      class SingleBatchQueue < TestQueue
        def initialize
          @queue = [[], [1]]
          super
        end

        def batch_size
          1
        end
      end

      class LowVolumeQueue < TestQueue
        def initialize
          @queue = [[], [1]]
          super
        end

        def batch_size
          5
        end
      end

      class DrainLoopTest < SchedulerTest
        test "does nothing when queue is empty" do
          setup_queue EmptyQueue.new

          ForemanTasks.expects(:async_task).never
          scheduler.expects(:sleep).never

          scheduler.drain_loop
        end

        test "spawns BulkGenerate" do
          setup_queue SingleBatchQueue.new

          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [1])
          scheduler.expects(:sleep).never

          scheduler.drain_loop
        end

        test "sleeps when queue is filling" do
          setup_queue LowVolumeQueue.new

          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [1])
          scheduler.expects(:sleep)

          scheduler.drain_loop
        end
      end

      class TriggerDrainTest < SchedulerTest
        test "spawns BulkGenerate" do
          setup_queue LowVolumeQueue.new
          scheduler.expects(:bulk_generate_tasks).returns([])
          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [1])

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "spawns scheduler task" do
          setup_queue LowVolumeQueue.new
          scheduler.expects(:bulk_generate_tasks).returns([:fake])

          ForemanTasks.expects(:async_task).with(Actions::Katello::Applicability::Scheduler)

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "does nothing when queue is empty" do
          setup_queue EmptyQueue.new
          ForemanTasks.expects(:async_task).never

          Katello::Applicability::Scheduler.trigger_drain
        end

        test "spawns nothing when scheduler task is running" do
          setup_queue LowVolumeQueue.new
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
