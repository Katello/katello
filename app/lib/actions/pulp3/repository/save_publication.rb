module Actions
  module Pulp3
    module Repository
      class SavePublication < Pulp3::Abstract
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, tasks, options = {})
          plan_self(:repository_id => repository.id, :tasks => tasks, :contents_changed => options[:contents_changed])
        end

        def run
          if input[:tasks] && input[:tasks][:pulp_tasks] && input[:tasks][:pulp_tasks].first
            publication_href = input[:tasks][:pulp_tasks].first[:created_resources].first
            if publication_href
              repo = ::Katello::Repository.find(input[:repository_id])
              repo_backend_service = repo.backend_service(SmartProxy.pulp_primary)
              publication = repo_backend_service.api.publications_api.read(publication_href, {fields: 'prn'})
              repo.update(:publication_href => publication_href, :publication_prn => publication.prn)
            end
          end
        end
      end
    end
  end
end
