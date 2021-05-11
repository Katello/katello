module Actions
  module Katello
    module Repository
      class InstanceUpdate < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository)
          action_subject repository
          repository.save!
          plan_action(::Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded, repository)
          plan_self(:repository_id => repository.id)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end
      end
    end
  end
end
