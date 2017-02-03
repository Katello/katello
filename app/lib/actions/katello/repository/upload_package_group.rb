module Actions
  module Katello
    module Repository
      class UploadPackageGroup < Actions::EntryAction
        def plan(repository, params)
          action_subject(repository)
          unit_key = {"repo_id": repository.pulp_id, "id": params[:name].parameterize.underscore}
          params = params.slice(:name, :description, :user_visible, :mandatory_package_names, :optional_package_names, :conditional_package_names, :default_package_names)

          sequence do
            upload_request = plan_action(Pulp::Repository::CreateUploadRequest)
            pkg_group_upload = plan_action(Pulp::Repository::ImportUpload,
                                           pulp_id: repository.pulp_id,
                                           unit_type_id: 'package_group',
                                           unit_key: unit_key,
                                           upload_id: upload_request.output[:upload_id],
                                           unit_metadata: params)

            plan_action(IndexPackageGroups, repository)
            plan_action(FinishUpload, repository, :dependency => pkg_group_upload.output, :generate_metadata => true)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Create Package Group")
        end
      end
    end
  end
end
