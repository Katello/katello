module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, tasks)
          plan_self(:repository_id => repository.id, :tasks => tasks)
        end

        def run
          version_href = input[:tasks].last[:created_resources].first
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_version = repo.backend_service(::SmartProxy.pulp_master).lookup_version version_href

          content_summary = repo_version.content_summary
          first_version = (repo_version.number == 1)
          output[:contents_changed] = first_version || !(content_summary.added.empty? && content_summary.removed.empty?)
          if version_href && output[:contents_changed]
            repo.update_attributes(:version_href => version_href)
          end
        end
      end
    end
  end
end
