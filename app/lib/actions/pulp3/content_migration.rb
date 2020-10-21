module Actions
  module Pulp3
    class ContentMigration < Pulp3::AbstractAsyncTask
      include Helpers::Presenter

      def plan(smart_proxy, options)
        sequence do
          action = plan_self(smart_proxy_id: smart_proxy.id)
          plan_action(Actions::Pulp3::ImportMigration, options.merge(:dependency => action.output))
        end
      end

      def invoke_external_task
        migration_service = ::Katello::Pulp3::Migration.new(smart_proxy)
        migration_service.create_and_run_migrations
      end

      def humanized_name
        _("Content Migration")
      end

      def presenter
        Actions::Pulp3::ContentMigrationPresenter.new(self)
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end
    end
  end
end
