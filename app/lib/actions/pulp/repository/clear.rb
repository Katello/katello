module Actions
  module Pulp
    module Repository
      class Clear < Actions::Pulp::AbstractAsyncTask
        def plan(repo, smart_proxy)
          plan_self(:repo_id => repo.id, :smart_proxy_id => smart_proxy.id) unless (repo.yum? || repo.empty_in_pulp?)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repo_id])
          ::Katello::RepositoryTypeManager.find(repo.content_type).content_types.map do |type|
            ::SmartProxy.find(input[:smart_proxy_id]).content_service(type).remove(repo)
          end
        end
      end
    end
  end
end
