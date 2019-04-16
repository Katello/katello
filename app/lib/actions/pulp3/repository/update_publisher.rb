module Actions
  module Pulp3
    module Repository
      class UpdatePublisher < Pulp3::Abstract
        def plan(repository, smart_proxy)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id) if repository.root.url?
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).update_publisher
        end
      end
    end
  end
end
