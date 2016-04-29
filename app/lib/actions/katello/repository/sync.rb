module Actions
  module Katello
    module Repository
      class Sync < Actions::EntryAction
        include Helpers::Presenter
        middleware.use Actions::Middleware::KeepCurrentUser
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :id, Integer
          param :sync_result, Hash
        end

        # @param repo
        # @param pulp_sync_task_id in case the sync was triggered outside
        #   of Katello and we just need to finish the rest of the orchestration
        # @param source_url optional url to override source URL with
        def plan(repo, pulp_sync_task_id = nil, source_url = nil, incremental = false)
          action_subject(repo)

          if repo.url.blank? && source_url.blank?
            fail _("Unable to sync repo. This repository does not have a feed url.")
          end

          if incremental && URI(source_url).scheme != 'file'
            fail _("URL must be of scheme 'file' for incremental import")
          end

          sequence do
            if incremental
              output = plan_action(Katello::Repository::IncrementalImport, repo,
                                    URI(source_url).path).output
            else
              output = plan_action(Pulp::Repository::Sync, pulp_id: repo.pulp_id,
                                   task_id: pulp_sync_task_id, source_url: source_url).output
            end

            contents_changed = output[:contents_changed]
            plan_action(Pulp::Repository::Publish, :pulp_id => repo.pulp_id,
                                                   :distributor_type_filter => ::Katello::Repository::PUBLISH_DISTRIBUTOR_TYPES,
                                                   :contents_changed => contents_changed)
            plan_action(Katello::Repository::IndexContent, :id => repo.id, :contents_changed => contents_changed)
            plan_action(Katello::Foreman::ContentUpdate, repo.environment, repo.content_view, repo)
            plan_action(Katello::Repository::CorrectChecksum, repo)
            concurrence do
              plan_action(Katello::Repository::UpdateMedia, :repo_id => repo.id, :contents_changed => contents_changed)
              plan_action(Katello::Repository::ErrataMail, repo, nil, contents_changed)
              plan_self(:id => repo.id, :sync_result => output, :user_id => ::User.current.id, :contents_changed => contents_changed)
              plan_action(Pulp::Repository::RegenerateApplicability, :pulp_id => repo.pulp_id, :contents_changed => contents_changed)
            end
            plan_action(Katello::Repository::ImportApplicability, :repo_id => repo.id, :contents_changed => contents_changed)
          end
        end

        def run
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
      end
    end
  end
end
