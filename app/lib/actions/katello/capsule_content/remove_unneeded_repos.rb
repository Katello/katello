module Actions
  module Katello
    module CapsuleContent
      class RemoveUnneededRepos < ::Actions::Base
        def plan(smart_proxy)
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)
          currently_on_capsule = smart_proxy_service.current_repositories.map(&:id)
          needed_on_capsule = smart_proxy_service.repos_available_to_capsule.map(&:id)

          need_removal = currently_on_capsule - needed_on_capsule
          need_removal.compact.each do |repo_id|
            plan_action(Pulp::Repository::Destroy,
                        :repository_id => repo_id,
                        :capsule_id => smart_proxy.id)
          end

          smart_proxy_service.delete_orphaned_repos
        end
      end
    end
  end
end
