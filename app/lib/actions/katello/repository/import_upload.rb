module Actions
  module Katello
    module Repository
      class ImportUpload < Actions::EntryAction
        def plan(repository, upload_id, unit_key = {})
          action_subject(repository)
          import_upload = plan_action(Pulp::Repository::ImportUpload,
                                      pulp_id: repository.pulp_id,
                                      unit_type_id: repository.unit_type_id,
                                      unit_key: unit_key,
                                      upload_id: upload_id)

          plan_action(FinishUpload, repository, import_upload.output)
        end

        def humanized_name
          _("Upload into")
        end
      end
    end
  end
end
