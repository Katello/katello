module Actions
  module Katello
    module CapsuleContent
      module RefreshRepos
        def fetch_proxy_service(_smart_proxy)
          fail NotImplementedError
        end

        def act_on_repo?(_repo)
          fail NotImplementedError
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip if self.state == 'error'
        end

        def plan(smart_proxy, options = {})
          plan_self(:smart_proxy_id => smart_proxy.id,
                    :environment_id => options[:environment]&.id,
                    :content_view_id => options[:content_view]&.id,
                    :repository_id => options[:repository]&.id)
        end

        def invoke_external_task
          tasks = []
          environment = ::Katello::KTEnvironment.find_by(:id => input[:environment_id]) if input[:environment_id]
          repository = ::Katello::Repository.find_by(:id => input[:repository_id]) if input[:repository_id]
          if repository.nil? && input[:repository_id]
            repository = ::Katello::ContentViewPuppetEnvironment.find(input[:repository_id])
            repository = repository.nonpersisted_repository
          end
          content_view = ::Katello::ContentView.find_by(:id => input[:content_view_id]) if input[:content_view_id]
          smart_proxy = SmartProxy.unscoped.find(input[:smart_proxy_id])
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_service = fetch_proxy_service(smart_proxy)

          current_repos_on_capsule = smart_proxy_service.current_repositories(environment, content_view)
          current_repos_on_capsule_ids = current_repos_on_capsule.pluck(:id)

          list_of_repos_to_sync = smart_proxy_helper.repos_available_to_capsule(environment, content_view, repository)
          list_of_repos_to_sync.each do |repo|
            if repo.is_a?(Katello::ContentViewPuppetEnvironment)
              repo = repo.nonpersisted_repository
            end
            next unless act_on_repo?(repo, smart_proxy)

            pulp_repo = repo.backend_service(smart_proxy)
            if !current_repos_on_capsule_ids.include?(repo.id)
              pulp_repo.create_mirror_entities
            elsif pulp_repo.mirror_needs_updates?
              tasks += pulp_repo.refresh_mirror_entities
            end
          end
          tasks
        end
      end
    end
  end
end
