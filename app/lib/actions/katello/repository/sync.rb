module Actions
  module Katello
    module Repository
      class Sync < Actions::EntryAction
        include Helpers::Presenter
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
          param :sync_result, Hash
        end

        # @param repo
        # @param pulp_sync_task_id in case the sync was triggered outside
        #   of Katello and we just need to finish the rest of the orchestration
        def plan(repo, pulp_sync_task_id = nil)
          sync_task = nil
          action_subject(repo)

          if repo.url.blank?
            fail _("Unable to sync %s. This repository does not have a feed url.")
          end

          sequence do
            sync_task = plan_action(Pulp::Repository::Sync, pulp_id: repo.pulp_id, task_id: pulp_sync_task_id)
            concurrence do
              plan_action(ElasticSearch::Repository::IndexContent, dependency: sync_task.output[:pulp_tasks], id: repo.id)
            end
            plan_action(ElasticSearch::Reindex, repo)
            plan_action(Katello::Foreman::ContentUpdate, repo.environment, repo.content_view)
            plan_action(Katello::Repository::CorrectChecksum, repo)
            concurrence do
              plan_action(Katello::Repository::UpdateMedia, repo)
              plan_action(Katello::Repository::ErrataMail, repo)
              plan_self(:id => repo.id, :sync_result => sync_task.output, :user_id => ::User.current.id)
              plan_action(Pulp::Repository::RegenerateApplicability, :pulp_id => repo.pulp_id)
            end
          end
        end

        def run
          output[:sync_result] = input[:sync_result]

          ForemanTasks.async_task(Repository::CapsuleGenerateAndSync, ::Katello::Repository.find(input[:id]))
        end

        def humanized_name
          _("Synchronize") # TODO: rename class to Synchronize and remove this method, add Sync = Synchronize
        end

        def presenter
          Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Repository::Sync))
        end

        def pulp_task_id
          pulp_action = planned_actions(Pulp::Repository::Sync).first
          if pulp_task = Array(pulp_action.external_task).first
            pulp_task.fetch(:task_id)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          repo = ::Katello::Repository.find(input[:id])
          repo.import_system_applicability
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
