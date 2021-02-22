module Actions
  module Pulp3
    class ContentMigrationReset < Pulp3::AbstractAsyncTask
      def plan(smart_proxy)
        plan_self(smart_proxy_id: smart_proxy.id)
      end

      def invoke_external_task
        migration_service = ::Katello::Pulp3::Migration.new(smart_proxy)
        migration_service.reset
      end

      def humanized_name
        _("Content Migration Reset")
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end
    end
  end
end
