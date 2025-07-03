module Actions
  module Katello
    module ContentView
      class AddRollingRepoClone < Actions::EntryAction
        include Helpers::SmartProxySyncHelper

        def plan(content_view, repository_ids)
          library = content_view.organization.library
          clone_ids = []

          concurrence do
            ::Katello::Repository.where(id: repository_ids).each do |repository|
              sequence do
                clone = content_view.get_repo_clone(library, repository).first
                if clone.nil?
                  clone = repository.build_clone(content_view: content_view, environment: library)
                  clone.save!
                end
                plan_action(RefreshRollingRepo, clone, false)

                view_env_cp_id = content_view.content_view_environment(library).cp_id
                content_id = repository.content_id
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env_cp_id, :content_id => content_id)
                clone_ids << clone.id
              end
            end
          end
          plan_self(repository_ids: clone_ids)
        end

        def run
          ::Katello::Repository.where(id: input[:repository_ids]).each do |repository|
            schedule_async_repository_proxy_sync(repository)
          end
        end
      end
    end
  end
end
