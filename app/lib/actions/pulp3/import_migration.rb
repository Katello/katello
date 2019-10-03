module Actions
  module Pulp3
    class ImportMigration < Pulp3::Abstract
      def plan(repository_type_labels)
        plan_self(repository_type_labels: repository_type_labels)
      end

      def run
        migration_service = ::Katello::Pulp3::Migration.new(SmartProxy.pulp_master, input[:repository_type_labels])
        migration_service.import_pulp3_content
      end
    end
  end
end
