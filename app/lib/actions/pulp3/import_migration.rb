module Actions
  module Pulp3
    class ImportMigration < Pulp3::Abstract
      def plan(options)
        plan_self(options)
      end

      def run
        migration_service = ::Katello::Pulp3::Migration.new(SmartProxy.pulp_primary)
        migration_service.import_pulp3_content
      end
    end
  end
end
