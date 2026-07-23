module Actions
  module Middleware
    # Records errata applications to database when errata install or package update tasks complete
    class RecordErrataApplication < Dynflow::Middleware
      TRACKED_FEATURES = %w[
        katello_errata_install
        katello_errata_install_by_search
        katello_package_update
        katello_packages_update_by_search
        katello_package_update_by_search
      ].freeze

      def finalize
        pass
      ensure
        record_if_errata_job
      end

      private

      def record_if_errata_job
        task = find_task
        return unless task
        return unless tracked_content_job?(task)

        ::Katello::ErrataApplication.record_from_task(task, action)
      rescue StandardError => e
        Rails.logger.error("Failed to record errata application: task=#{task&.id}, error=#{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end

      def find_task
        return nil unless action.execution_plan_id

        features = action.input['job_features']
        return nil unless features && (features & TRACKED_FEATURES).any?

        ::ForemanTasks::Task.where(
          external_id: action.execution_plan_id,
          label: 'Actions::RemoteExecution::RunHostJob'
        ).first
      end

      def tracked_content_job?(task)
        return false unless task.template_invocation
        return false unless task.template_invocation.template

        task.template_invocation.template.remote_execution_features
          .where(label: TRACKED_FEATURES)
          .exists?
      end
    end
  end
end
