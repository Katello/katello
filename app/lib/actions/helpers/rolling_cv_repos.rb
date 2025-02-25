module Actions
  module Helpers
    module RollingCVRepos
      def concerned_repos(repo)
        repo.root.repositories.in_environment(repo.environment).where(
          content_view_version: ::Katello::ContentViewVersion.where(content_view: ::Katello::ContentView.rolling)
        )
      end

      def update_rolling_content_views(repo)
        concurrence do
          concerned_repos(repo).each do |rolling_repo|
            plan_action(::Actions::Katello::ContentView::RefreshRollingRepo, rolling_repo)
          end
        end
      end

      def update_rolling_content_views_async(repo)
        concerned_repos(repo).each do |rolling_repo|
          ForemanTasks.sync_task(::Actions::Katello::ContentView::RefreshRollingRepo, rolling_repo)
        end
      end
    end
  end
end
