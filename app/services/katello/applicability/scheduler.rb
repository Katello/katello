module Katello
  module Applicability
    class Scheduler
      ActiveSupport::Notifications.subscribe("applicability_push_hosts") do
        trigger_drain
      end

      # The purpose of this mutex is to avoid bombarding Dynflow
      # with events to trigger applicability calculation. Each event received
      # causes a tick of the drain loop which is unnecessary work.
      # It also saves a few database queries here.
      TRIGGER_MUTEX = Mutex.new

      def self.scheduler_task
        ::ForemanTasks::Task::DynflowTask.running.for_action(Actions::Katello::Applicability::Scheduler).first
      end

      def self.trigger_scheduler_task
        ForemanTasks.trigger(Actions::Katello::Applicability::Scheduler)
      end

      # Alternative to this, the Scheduler action could just poll in a loop.
      def self.trigger_drain
        return if TRIGGER_MUTEX.locked?

        TRIGGER_MUTEX.synchronize do
          return if Katello::ApplicableHostQueue.queue_depth == 0
          return unless scheduler_task # Anything else to do in this scenario?

          ForemanTasks.dynflow.world.event(scheduler_task.external_id, 2, nil)
          Rails.logger.info "Host applicability generation scheduled"
        end
      end
    end
  end
end
