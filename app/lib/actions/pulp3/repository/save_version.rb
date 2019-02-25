module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, tasks)
          plan_self(:repository_id => repository.id, :tasks => tasks)
        end

        def run
          publication_href = input[:tasks].first[:created_resources].first
          if publication_href
            repo = ::Katello::Repository.find(input[:repository_id])
            repo.update_attributes(:version_href => publication_href)
          end
        end
      end
    end
  end
end
