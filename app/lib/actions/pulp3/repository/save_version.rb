module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, options)
          plan_self(:repository_id => repository.id, :tasks => options[:tasks], :repository_details => options[:repository_details])
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])

          if input[:tasks]
            version_href = input[:tasks].last[:created_resources].first
          end

          if !version_href && input[:repository_details]
            version_href = input[:repository_details][:latest_version_href]
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
