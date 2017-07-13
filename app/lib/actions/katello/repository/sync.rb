# rubocop:disable HandleExceptions
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
        def plan(repo, pulp_sync_task_id = nil, options = {})
          action_subject(repo)

          source_url = options.fetch(:source_url, nil)
          incremental = options.fetch(:incremental, false)
          validate_contents = options.fetch(:validate_contents, false)
          skip_metadata_check = options.fetch(:skip_metadata_check, false) || validate_contents

          pulp_sync_options = {}
          pulp_sync_options[:download_policy] = ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND if validate_contents
          pulp_sync_options[:force_full] = true if skip_metadata_check
          pulp_sync_options[:remove_missing] = false if incremental

          fail ::Katello::Errors::InvalidActionOptionError, _("Unable to sync repo. This repository does not have a feed url.") if repo.url.blank? && source_url.blank?
          fail ::Katello::Errors::InvalidActionOptionError, _("Cannot validate contents on non-yum repositories.") if validate_contents && !repo.yum?
          fail ::Katello::Errors::InvalidActionOptionError, _("Cannot skip metadata check on non-yum repositories.") if skip_metadata_check && !repo.yum?

          sequence do
            sync_args = {:pulp_id => repo.pulp_id, :task_id => pulp_sync_task_id, :source_url => source_url, :options => pulp_sync_options}
            output = plan_action(Pulp::Repository::Sync, sync_args).output

            contents_changed = skip_metadata_check || output[:contents_changed]
            plan_action(Katello::Repository::IndexContent, :id => repo.id, :contents_changed => contents_changed, :full_index => skip_metadata_check)
            plan_action(Katello::Foreman::ContentUpdate, repo.environment, repo.content_view, repo)
            plan_action(Katello::Repository::CorrectChecksum, repo)
            concurrence do
              plan_action(Pulp::Repository::Download, :pulp_id => repo.pulp_id, :options => {:verify_all_units => true}) if validate_contents
              plan_action(Katello::Repository::MetadataGenerate, repo, :force => true) if skip_metadata_check
              plan_action(Katello::Repository::ErrataMail, repo, nil, contents_changed)
              plan_action(Pulp::Repository::RegenerateApplicability, :pulp_id => repo.pulp_id, :contents_changed => contents_changed)
            end
            plan_self(:id => repo.id, :sync_result => output, :skip_metadata_check => skip_metadata_check, :validate_contents => validate_contents,
                      :contents_changed => contents_changed)
            plan_action(Katello::Repository::ImportApplicability, :repo_id => repo.id, :contents_changed => contents_changed)
          end
        end

        def run
          ForemanTasks.async_task(Repository::CapsuleGenerateAndSync, ::Katello::Repository.find(input[:id]))
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def humanized_name
          if input[:validate_contents]
            _("Synchronize: Validate Content")
          elsif input[:skip_metadata_check]
            _("Synchronize: Skip Metadata Check")
          else
            _("Synchronize")
          end
        end

        def presenter
          Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Repository::Sync))
        end

        def pulp_task_id
          pulp_action = planned_actions(Pulp::Repository::Sync).first
          if (pulp_task = Array(pulp_action.external_task).first)
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
