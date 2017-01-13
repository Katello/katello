module Actions
  module Katello
    module Repository
      class ImportUpload < Actions::EntryAction
        def plan(repository, upload_id, options = {})
          action_subject(repository)
          unit_key = options.fetch(:unit_Key, {})
          generate_metadata = options.fetch(:generate_metadata, true)
          import_upload = plan_action(Pulp::Repository::ImportUpload,
                                      pulp_id: repository.pulp_id,
                                      unit_type_id: repository.unit_type_id,
                                      unit_key: unit_key,
                                      upload_id: upload_id)

          plan_action(FinishUpload, repository, :dependency => import_upload.output, :generate_metadata => generate_metadata)
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
