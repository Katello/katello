module Katello
  module Applicability
    class Scheduler
      ActiveSupport::Notifications.subscribe("applicability_push_hosts") do
        trigger_drain
      end

      DRAIN_MUTEX = Mutex.new
      DRAIN_SLEEP_SECONDS = 3

      def self.scheduler_task
        ::ForemanTasks::Task::DynflowTask.running.for_action(Actions::Katello::Applicability::Scheduler).first
      end

      def self.trigger_scheduler_task
        ForemanTasks.async_task(Actions::Katello::Applicability::Scheduler)
      end

      def self.bulk_generate_tasks
        ::ForemanTasks::Task::DynflowTask.running.for_action(Actions::Katello::Applicability::Hosts::BulkGenerate)
      end

      def self.drain_loop
        until (host_ids = ::Katello::ApplicableHostQueue.pop_hosts).empty?
          begin
            ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: host_ids)
          rescue => e
            Rails.logger.error("Error while draining applicability queue #{e}")
          end

          sleep DRAIN_SLEEP_SECONDS unless host_ids.length == ::Katello::ApplicableHostQueue.batch_size # allow some time for the queue to fill
        end
      end

      def self.trigger_drain
        return if DRAIN_MUTEX.locked?

        DRAIN_MUTEX.synchronize do
          depth = Katello::ApplicableHostQueue.queue_depth
          return if depth == 0
          return if scheduler_task

          if depth < Katello::ApplicableHostQueue.batch_size && bulk_generate_tasks.empty?
            host_ids = Katello::ApplicableHostQueue.pop_hosts
            ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: host_ids)
          else
            # High applicability activity detected
            trigger_scheduler_task
          end
        end
      end
    end
  end
end
