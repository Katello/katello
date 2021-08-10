module Actions
  module Pulp3
    module Repository
      class Create < Pulp3::Abstract
        def plan(repository, smart_proxy, force = false)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :force => force)
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])
          force = input[:force] || false
          output[:response] = repo.backend_service(smart_proxy).with_mirror_adapter.create(force)
        end
      end
    end
  end
end
