module Actions
  module Helpers
    module RollingCVRepos
      def find_related_rolling_repos(repo)
        repo.root.repositories.where(
          content_view_version: ::Katello::ContentViewVersion.where(content_view: ::Katello::ContentView.rolling)
        )
      end

      def update_rolling_content_views(repo)
        concurrence do
          find_related_rolling_repos(repo).each do |rolling_repo|
            plan_action(::Actions::Katello::ContentView::RefreshRollingRepo, rolling_repo, true)
          end
        end
      end

      def update_rolling_content_views_async(repo, contents_changed)
        find_related_rolling_repos(repo).each do |rolling_repo|
          ForemanTasks.async_task(::Actions::Katello::ContentView::RefreshRollingRepo, rolling_repo, contents_changed)
        end
      end
    end
  end
end
