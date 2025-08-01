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
          delete_repo_from_smartproxy = []
          output[:delete_repo_from_smartproxy] = []
          repos_to_delete = ::Katello::Repository.where(id: input[:repository_ids])
          repos_to_delete.each do |repo|
            SmartProxy.with_repo(repo).each do |proxy|
              delete_repo_from_smartproxy << { proxy: proxy.id, repo: repo.id } unless proxy.pulp_primary?
            end
          end
          repos_to_delete.destroy_all
          input[:delete_repo_from_smartproxy] = delete_repo_from_smartproxy
        end

        def finalize
          input[:delete_repo_from_smartproxy].each do |entry|
            ForemanTasks.async_task(::Actions::Katello::CapsuleContent::UpdateContentCounts, SmartProxy.find(entry[:proxy]), repository_id: entry[:repo])
          end
        end
      end
    end
  end
end
