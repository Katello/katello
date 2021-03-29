# rubocop:disable Lint/SuppressedException
module Actions
  module Katello
    module Repository
      class Sync < Actions::EntryAction
        extend ApipieDSL::Class
        include Helpers::Presenter
        include Actions::Katello::PulpSelector
        include ::Actions::ObservableAction
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :id, Integer
          param :sync_result, Hash
        end

        # @param repo
        # @param pulp_sync_task_id in case the sync was triggered outside
        #   of Katello and we just need to finish the rest of the orchestration
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/AbcSize
        def plan(repo, _pulp_sync_task_id = nil, options = {})
          action_subject(repo)

          source_url = options.fetch(:source_url, nil)
          incremental = options.fetch(:incremental, false)
          validate_contents = options.fetch(:validate_contents, false)
          skip_metadata_check = options.fetch(:skip_metadata_check, false) || (validate_contents && repo.yum?)
          generate_applicability = repo.yum?

          fail ::Katello::Errors::InvalidActionOptionError, _("Unable to sync repo. This repository does not have a feed url.") if repo.url.blank? && source_url.blank?
          fail ::Katello::Errors::InvalidActionOptionError, _("Cannot validate contents on non-yum/deb repositories.") if validate_contents && !repo.yum? && !repo.deb?
          fail ::Katello::Errors::InvalidActionOptionError, _("Cannot skip metadata check on non-yum repositories.") if skip_metadata_check && !repo.yum?

          pulp_sync_options = {}
          pulp_sync_options[:download_policy] = ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND if validate_contents && repo.yum?

          #pulp2 options
          pulp_sync_options[:force_full] = true if skip_metadata_check && repo.yum?
          pulp_sync_options[:repair_sync] = true if validate_contents && repo.deb?
          pulp_sync_options[:remove_missing] = false if incremental
          pulp_sync_options[:source_url] = source_url

          #pulp3 options
          pulp_sync_options[:optimize] = false if skip_metadata_check && repo.yum?

          sequence do
            if SmartProxy.pulp_primary.pulp3_support?(repo) && validate_contents
              plan_action(Katello::Repository::VerifyChecksum, repo)
            else
              plan_action(Pulp::Repository::RemoveUnits, :repo_id => repo.id, :content_unit_type => ::Katello::YumMetadataFile::CONTENT_TYPE) if validate_contents && repo.yum?
              sync_action = plan_pulp_action([Actions::Pulp::Orchestration::Repository::Sync,
                                              Actions::Pulp3::Orchestration::Repository::Sync],
                                             repo,
                                             SmartProxy.pulp_primary,
                                             pulp_sync_options)
              output = sync_action.output

              contents_changed = skip_metadata_check || output[:contents_changed]

              plan_action(Katello::Repository::IndexContent, :id => repo.id, :contents_changed => contents_changed)
              plan_action(Katello::Foreman::ContentUpdate, repo.environment, repo.content_view, repo)
              plan_action(Katello::Repository::FetchPxeFiles, :id => repo.id)
              plan_action(Katello::Repository::CorrectChecksum, repo)
              concurrence do
                plan_action(Pulp::Repository::Download, :pulp_id => repo.pulp_id, :options => {:verify_all_units => true}) if validate_contents && repo.yum?
                plan_action(Katello::Repository::MetadataGenerate, repo, :force => true) if skip_metadata_check && repo.yum?
                plan_action(Katello::Repository::ErrataMail, repo, nil, contents_changed)
                if generate_applicability
                  regenerate_applicability(repo, contents_changed)
                end
              end
              plan_self(:id => repo.id, :sync_result => output, :skip_metadata_check => skip_metadata_check, :validate_contents => validate_contents,
                        :contents_changed => contents_changed)
              plan_action(Katello::Repository::ImportApplicability, :repo_id => repo.id, :contents_changed => contents_changed) if generate_applicability
              plan_action(Katello::Repository::SyncHook, :id => repo.id)
            end
          end
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          repo.clear_smart_proxy_sync_histories if input[:contents_changed]
          ForemanTasks.async_task(Repository::CapsuleSync, repo) if Setting[:foreman_proxy_content_auto_sync]
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def finalize
          ::Katello::Repository.find(input[:id])&.audit_sync
        end

        def humanized_name
          if input && input[:validate_contents]
            _("Synchronize: Validate Content")
          elsif input && input[:skip_metadata_check]
            _("Synchronize: Skip Metadata Check")
          else
            _("Synchronize")
          end
        end

        def presenter
          found = all_planned_actions(Pulp::Repository::Sync)
          found = all_planned_actions(Pulp3::Repository::Sync) if found.empty?
          found = all_planned_actions(Pulp3::Repository::Repair) if found.empty?
          Helpers::Presenter::Delegated.new(self, found)
        end

        def pulp_task_id
          pulp_action = planned_actions(Pulp::Repository::Sync).first
          if (pulp_task = Array(pulp_action.external_task).first)
            pulp_task.fetch(:task_id)
          end
        end

        def regenerate_applicability(repo, contents_changed)
          if SETTINGS[:katello][:katello_applicability]
            plan_action(Actions::Katello::Applicability::Repository::Regenerate, :repo_id => repo.id, :contents_changed => contents_changed)
          else
            plan_action(Pulp::Repository::RegenerateApplicability, :repository_id => repo.id, :contents_changed => contents_changed)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def repository_id
          input['repository']['id']
        end

        def repository_name
          input['repository']['name']
        end

        def repository_label
          input['repository']['label']
        end

        def product_id
          input['product']['id']
        end

        def product_name
          input['product']['name']
        end

        def product_label
          input['product']['label']
        end

        def contents_changed
          input['contents_changed']
        end

        def sync_result
          input['sync_result']
        end

        apipie :class, "A class representing #{self} object" do
          desc 'This object is available as **@object** variable in
                webhook templates when a corresponding event occures.
                The following properties can be used to retrieve the needed information.'
          name "#{class_scope}"
          refs "#{class_scope}"
          sections only: %w[all webhooks]
          property :task, object_of: 'Task', desc: 'Returns the task to which this action belongs'
          property :repository_id, Integer, desc: 'Returns synced repository id'
          property :repository_name, String, desc: 'Returns synced repository name'
          property :repository_label, String, desc: 'Returns synced repository label'
          property :product_id, Integer, desc: 'Returns product id the synced repository belongs to'
          property :product_name, String, desc: 'Returns product name the synced repository belongs to'
          property :product_label, String, desc: 'Returns product label the synced repository belongs to'
          property :sync_result, Hash, desc: 'Returns Hash object with sync result'
          property :contents_changed, one_of: [true, false], desc: 'Returns true if repository content was changed due to sync, false otherwise'
        end
        include Actions::Katello::JailConcern::Organization
        class Jail < ::Actions::ObservableAction::Jail
          allow :organization_id, :organization_name, :organization_label,
                :repository_id, :repository_name, :repository_label,
                :product_id, :product_name, :product_label,
                :sync_result, :contents_changed
        end
      end
    end
  end
end
