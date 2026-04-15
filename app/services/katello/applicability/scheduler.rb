module Katello
  module Applicability
    class Scheduler
      ActiveSupport::Notifications.subscribe("applicability_push_hosts") do
        trigger_drain
      end

      DRAIN_MUTEX = Mutex.new
      DRAIN_SLEEP_SECONDS = 3

      def self.queue
        Katello::ApplicableHostQueue
      end

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
        catch(:done) do
          loop do
            ids = queue.pop_hosts do |host_ids|
              throw(:done) if host_ids.empty?

              ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: host_ids)
            end
            sleep DRAIN_SLEEP_SECONDS unless ids.length == queue.batch_size # allow some time for the queue to fill
          end
        end
      end

      def self.trigger_drain
        return if DRAIN_MUTEX.locked?

        DRAIN_MUTEX.synchronize do
          depth = queue.queue_depth
          return if depth == 0
          return if scheduler_task

          if depth < queue.batch_size && bulk_generate_tasks.empty?
            queue.pop_hosts do |host_ids|
              ForemanTasks.async_task(Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: host_ids)
            end
          else
            # High applicability activity detected
            begin
              trigger_scheduler_task
            rescue RuntimeError => e
              # Scheduler already started
              Rails.logger.error "[applicability] #{e}"
            end
          end
        end
      end
    end
  end
end
