module Actions
  module Katello
    module ContentView
      class RemoveRollingRepoClone < Actions::EntryAction
        def plan(content_view, repository_ids, environment_ids)
          clone_ids = []
          environments = ::Katello::KTEnvironment.where(id: environment_ids)
          repositories = ::Katello::Repository.where(id: repository_ids)

          sequence do
            environments.each do |environment|
              concurrence do
                repositories.each do |repository|
                  clone_repo = content_view.get_repo_clone(environment, repository).first
                  next if clone_repo.nil?

                  clone_ids << clone_repo.id
                  plan_action(Actions::Pulp3::Repository::DeleteDistributions, clone_repo.id, SmartProxy.pulp_primary)
                end
                plan_action(Candlepin::Environment::SetContent, content_view, environment, content_view.content_view_environment(environment))
              end
            end
            plan_self(repository_ids: clone_ids)
          end
        end

        def run
          ::Katello::Repository.where(id: input[:repository_ids]).each do |repository|
            SmartProxy.unscoped.with_repo(repository).each do |smart_proxy|
              next if smart_proxy.pulp_primary?

              smart_proxy.content_counts&.dig("content_view_versions", repository.content_view_version_id.to_s, "repositories")&.delete(repository.id.to_s)
              smart_proxy.save
            end
            repository.destroy!
          end
        end
      end
    end
  end
end
