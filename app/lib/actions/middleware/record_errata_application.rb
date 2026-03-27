module Actions
  module Middleware
    # Records errata applications to database when errata installation tasks complete
    class RecordErrataApplication < Dynflow::Middleware
      def finalize
        pass.tap { record_if_errata_job }
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

        if action.is_a?(::Actions::RemoteExecution::RunHostJob)
          ::ForemanTasks::Task.where(external_id: action.execution_plan_id, label: action.class.name).first
        else
          ::ForemanTasks::Task.find_by(external_id: action.execution_plan_id)
        end
      end

      def errata_install_job?(task)
        if action.is_a?(::Actions::RemoteExecution::RunHostJob)
          return false unless task.template_invocation

          ::TemplateInvocationInputValue
            .joins(:template_input)
            .where(template_invocation_id: task.template_invocation.id)
            .where("template_inputs.name IN (?)", ['errata', 'Errata search query'])
            .exists?
        else
          %w[
            Actions::Katello::Host::Erratum::Install
            Actions::Katello::Host::Erratum::ApplicableErrataInstall
          ].include?(action.label.to_s)
        end
      end
    end
  end
end
