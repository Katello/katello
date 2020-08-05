module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, options)
          plan_self(:repository_id => repository.id, :tasks => options[:tasks], :repository_details => options[:repository_details])
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])

          if input[:tasks].present?
            version_href = input[:tasks].last[:created_resources].first
          end

          if !version_href
            if input[:repository_details]
              version_href = input[:repository_details][:latest_version_href]
            elsif repo.version_href.nil?
              # Fetch latest Pulp 3 repo version
              repo_backend_service = repo.backend_service(SmartProxy.pulp_master)
              version_href ||= repo_backend_service.api.
                repositories_api.read(repo_backend_service.
                repository_reference.repository_href).latest_version_href
            end
          end

          if version_href
            repo.update(:version_href => version_href)
            output[:contents_changed] = true
          else
            output[:contents_changed] = false
          end
        end
      end
    end
  end
end
