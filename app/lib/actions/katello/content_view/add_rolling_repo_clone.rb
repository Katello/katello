module Actions
  module Katello
    module ContentView
      class AddRollingRepoClone < Actions::EntryAction
        def plan(content_view, repository_ids)
          library = content_view.organization.library

          concurrence do
            ::Katello::Repository.where(id: repository_ids).each do |repository|
              sequence do
                clone = content_view.get_repo_clone(library, repository).first
                if clone.nil?
                  clone = repository.build_clone(content_view: content_view, environment: library)
                  clone.save!
                end
                plan_action(RefreshRollingRepo, clone)

                view_env_cp_id = content_view.content_view_environment(library).cp_id
                content_id = repository.content_id
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env_cp_id, :content_id => content_id)
              end
            end
          end
        end
      end
    end
  end
end
