module Actions
  module Katello
    module Repository
      class UpdateRedhatRepository < Actions::EntryAction
        def plan(repo)
          action_subject repo
          repo.root.update!(:url => upstream_url(repo)) if repo.library_instance?
          repo.update!(relative_path: relative_path(repo))
          plan_action(::Actions::Katello::Repository::RefreshRepository, repo)
          plan_self(:repository_id => repo.id)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::UpdateMetadataSync, repository)
        end

        private

        def relative_path(repo)
          repo.generate_repo_path(repo.generate_content_path)
        end

        def upstream_url(repo)
          repo.product.repo_url(repo.generate_content_path)
        end
      end
    end
  end
end
