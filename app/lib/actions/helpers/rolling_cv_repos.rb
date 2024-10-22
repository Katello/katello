module Actions
  module Helpers
    module RollingCVRepos
      def update_rolling_content_views(repo)
        concurrence do
          repos = repo.root.repositories.in_environment(repo.environment).where(
            content_view_version: ::Katello::ContentViewVersion.where(content_view: ::Katello::ContentView.rolling)
          )

          repos.each do |rolling_repo|
            plan_action(::Actions::Katello::ContentView::RefreshRollingRepo, rolling_repo)
          end
        end
      end
    end
  end
end
