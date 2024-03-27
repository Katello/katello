module Actions
  module Pulp3
    module CapsuleContent
      class VerifyChecksum < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:pulp_tasks] = repo.backend_service(smart_proxy).with_mirror_adapter.repair
        end

        def repos_to_repair(smart_proxy, environment, content_view, repository)
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_helper.lifecycle_environment_check(environment, repository)
          if repository
            [repository]
          else
            repositories = smart_proxy_helper.repositories_available_to_capsule(environment, content_view).by_rpm_count
            repositories
          end
        end
      end
    end
  end
end
