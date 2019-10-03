module Actions
  module Pulp3
    class ContentMigration < Pulp3::AbstractAsyncTask
      def plan(repository_type_labels, smart_proxy = SmartProxy.pulp_master)
        sequence do
          plan_self(repository_type_labels: repository_type_labels, smart_proxy_id: smart_proxy.id)
          plan_action(Actions::Pulp3::ImportMigration, repository_type_labels)
        end
      end

      def invoke_external_task
        migration_service = ::Katello::Pulp3::Migration.new(smart_proxy, input[:repository_type_labels])
        migration_service.create_and_run_migration
      end
    end
  end
end
