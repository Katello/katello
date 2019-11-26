module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, tasks)
          plan_self(:repository_id => repository.id, :tasks => tasks)
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])
          version_href = input[:tasks].last[:created_resources].first

          # Assumption that repo.version_href being nil means the repo was just created
          if version_href.nil? && repo.version_href.nil?
            version_href = input[:tasks].last[:reserved_resources_record].first + "versions/0/"
          end

          if version_href
            repo_version = repo.backend_service(::SmartProxy.pulp_master).lookup_version(version_href)
            content_summary = repo_version.content_summary
            first_version = (repo_version.number == 0)
            output[:contents_changed] = first_version || !(content_summary.added.empty? && content_summary.removed.empty?)
            if output[:contents_changed]
              repo.update_attributes(:version_href => version_href)
            end
          else
            output[:contents_changed] = false
          end
        end
      end
    end
  end
end
