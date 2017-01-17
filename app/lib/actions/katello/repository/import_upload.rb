# rubocop:disable HandleExceptions
module Actions
  module Katello
    module Repository
      class ImportUpload < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository, upload_ids, options = {})
          action_subject(repository)
          unit_keys = options.fetch(:unit_keys, {})
          generate_metadata = options.fetch(:generate_metadata, true)
          sync_capsule = options.fetch(:sync_capsule, true)
          sequence do
            concurrence do
              upload_ids.zip(unit_keys) do |upload_id, unit_key|
                import_upload = plan_action(Pulp::Repository::ImportUpload,
                                            pulp_id: repository.pulp_id,
                                            unit_type_id: repository.unit_type_id,
                                            unit_key: unit_key,
                                            upload_id: upload_id)

                plan_action(FinishUpload, repository, :dependency => import_upload.output,
                            generate_metadata: false)
              end
            end
            plan_action(Katello::Repository::MetadataGenerate, repository) if generate_metadata
            plan_self(repository_id: repository.id, sync_capsule: sync_capsule)
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          if input[:sync_capsule]
            ForemanTasks.async_task(Katello::Repository::CapsuleGenerateAndSync, repository)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Upload into")
        end
      end
    end
  end
end
