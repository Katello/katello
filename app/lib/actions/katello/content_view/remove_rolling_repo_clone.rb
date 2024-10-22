module Actions
  module Katello
    module ContentView
      class RemoveRollingRepoClone < Actions::EntryAction
        def plan(content_view, repository_ids)
          library = content_view.organization.library

          clone_repo_ids = []
          concurrence do
            ::Katello::Repository.where(id: repository_ids).each do |repository|
              clone_repo = content_view.get_repo_clone(library, repository).first
              next if clone_repo.nil?

              clone_repo_ids << clone_repo.id
              plan_action(Actions::Pulp3::Repository::DeleteDistributions, clone_repo.id, SmartProxy.pulp_primary)
            end
            plan_action(Candlepin::Environment::SetContent, content_view, library, content_view.content_view_environment(library))
          end
          plan_self(repository_ids: clone_repo_ids)
        end

        def run
          ::Katello::Repository.where(id: input[:repository_ids]).destroy_all
        end
      end
    end
  end
end
