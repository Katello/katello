module Actions
  module Katello
    module CapsuleContent
      class CreateRepos < ::Actions::EntryAction
        def plan(smart_proxy, environment = nil, content_view = nil, repository = nil)
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)
          fail _("Action not allowed for the default capsule.") if smart_proxy_service.default_capsule?

          repos_to_create(smart_proxy_service, environment, content_view, repository).each do |repo|
            plan_action(Pulp::Repository::Create, repo, smart_proxy)
          end
        end

        def repos_to_create(smart_proxy_service, environment, content_view, repository)
          repos = []
          current_repos_on_capsule = smart_proxy_service.current_repositories(environment, content_view)

          if repository
            unless current_repos_on_capsule.include?(repository)
              repos << repository
            end
          else
            list_of_repos_to_sync = smart_proxy_service.repos_available_to_capsule(environment, content_view)
            repos = list_of_repos_to_sync - current_repos_on_capsule
          end
          repos
        end
      end
    end
  end
end
