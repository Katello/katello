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

          if version_href
            repo.update_attributes(:version_href => version_href)
            output[:contents_changed] = true
          else
            output[:contents_changed] = false
          end
        end
      end
    end
  end
end
