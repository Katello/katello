module Actions
  module Pulp3
    module Repository
      class SavePublication < Pulp3::Abstract
        def plan(repository, tasks)
          plan_self(:repository_id => repository.id, :tasks => tasks)
        end

        def run
          if input[:tasks] && input[:tasks].first
            publication_href = input[:tasks].first[:created_resources].first
            if publication_href
              repo = ::Katello::Repository.find(input[:repository_id])
              repo.update_attributes(:publication_href => publication_href)
            end
          end
        end
      end
    end
  end
end
