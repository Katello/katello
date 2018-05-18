module Actions
  module Helpers
    module Notifications
      def self.included(base)
        base.execution_plan_hooks.use :send_notification, :on => [:stopped]
      end

      def send_notification(plan)
        if plan_failed?(plan)
          failure_notification(plan)
        else
          success_notification(plan)
        end
      end

      def success_notification(plan)
      end

      def failure_notification(plan)
      end

      def plan_failed?(plan)
        [:error, :warning, :cancelled].include?(plan.result)
      end

      def subject_organization
        @organization ||= ::Organization.find(input[:organization][:id])
      end

      def get_foreman_task(plan)
        ::ForemanTasks::Task::DynflowTask.where(:external_id => plan.id).first
      end
    end
  end
end
