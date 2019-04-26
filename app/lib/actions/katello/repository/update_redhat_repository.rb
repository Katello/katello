module Actions
  module Katello
    module Repository
      class UpdateRedhatRepository < Actions::EntryAction
        def plan(repo)
          action_subject repo
          repo.root.update_attributes!(:url => upstream_url(repo)) if repo.library_instance?
          repo.update_attributes!(relative_path: relative_path(repo))
          plan_action(::Actions::Pulp::Repository::Refresh, repo)
          plan_self(:repository_id => repo.id)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end

        private

        def path(repo)
          path = repo.content.content_url
          repo.root.substitutions.each do |key, value|
            path = path.gsub("$#{key}", value) if value
          end
          path
        end

        def relative_path(repo)
          ::Katello::Glue::Pulp::Repos.repo_path_from_content_path(repo.environment, path(repo))
        end

        def upstream_url(repo)
          repo.product.repo_url(path(repo))
        end
      end
    end
  end
end
