module Actions
  module Katello
    module ContentView
      class AddRollingRepoClone < Actions::EntryAction
        def plan(content_view, repository_ids, environment_ids)
          clone_ids = []
          environments = ::Katello::KTEnvironment.where(id: environment_ids)
          repositories = ::Katello::Repository.where(id: repository_ids)

          environments.each do |environment|
            concurrence do
              repositories.each do |repository|
                sequence do
                  clone = content_view.get_repo_clone(environment, repository).first
                  if clone.nil?
                    clone = repository.build_clone(content_view: content_view, environment: environment)
                    clone.save!
                  end
                  plan_action(RefreshRollingRepo, clone, false)

                  view_env_cp_id = content_view.content_view_environment(environment).cp_id
                  content_id = repository.content_id
                  plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env_cp_id, :content_id => content_id)
                  clone_ids << clone.id
                end
              end
            end
          end
        end
      end
    end
  end
end
