module Actions
  module Pulp3
    class ImportMigration < Pulp3::Abstract
      def plan(options)
        plan_self(options)
      end

      def run
        task_id = ForemanTasks::Task.find_by(external_id: self.execution_plan_id)&.id
        migration_service = ::Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, input.merge(task_id: task_id))
        migration_service.import_pulp3_content
      end

      def humanized_output
        output[:status]
      end
    end
  end
end
