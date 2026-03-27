module Actions
  module Middleware
    # Records errata applications to database when errata installation tasks complete
    class RecordErrataApplication < Dynflow::Middleware
      def finalize
        pass
      ensure
        record_if_errata_job
      end

      private

      def record_if_errata_job
        task = find_task
        return unless task
        return unless errata_install_job?(task)

        ::Katello::ErrataApplication.record_from_task(task, action)
      rescue StandardError => e
        Rails.logger.error("Failed to record errata application: task=#{task&.id}, error=#{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end

      def find_task
        return nil unless action.execution_plan_id

        features = action.input['job_features']
        return nil unless features && (features & ['katello_errata_install', 'katello_errata_install_by_search']).any?

        ::ForemanTasks::Task.where(
          external_id: action.execution_plan_id,
          label: 'Actions::RemoteExecution::RunHostJob'
        ).first
      end

      def errata_install_job?(task)
        return false unless task.template_invocation
        return false unless task.template_invocation.template

        task.template_invocation.template.remote_execution_features
          .where(label: ['katello_errata_install', 'katello_errata_install_by_search'])
          .exists?
      end
    end
  end
end
