module Actions
  module Pulp3
    class ImportMigration < Pulp3::Abstract
      def plan
        plan_self
      end

      def run
        migration_service = ::Katello::Pulp3::Migration.new(SmartProxy.pulp_master)
        migration_service.import_pulp3_content
      end
    end
  end
end
