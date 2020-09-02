module Actions
  module Pulp3
    class ContentMigration < Pulp3::AbstractAsyncTask
      def plan(smart_proxy = SmartProxy.pulp_primary)
        sequence do
          plan_self(smart_proxy_id: smart_proxy.id)
          plan_action(Actions::Pulp3::ImportMigration)
        end
      end

      def invoke_external_task
        migration_service = ::Katello::Pulp3::Migration.new(smart_proxy)
        migration_service.create_and_run_migrations
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end
    end
  end
end
