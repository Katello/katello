module Actions
  module Katello
    module Repository
      class Clear < Actions::Base
        def plan(repo)
          plan_self(:repo_id => repo.id)
        end

        def run
          repo = ::Katello::Repository.find(input[:repo_id])
          ::Katello::RepositoryTypeManager.find(repo.content_type).content_types.each do |type|
            ::SmartProxy.pulp_master.content_service(type).remove(repo)
          end
        end
      end
    end
  end
end
