module Actions
  module Katello
    module Repository
      class UploadPackageGroup < Actions::EntryAction
        def plan(repository, _params)
          action_subject(repository)

          sequence do
            plan_action(IndexPackageGroups, repository)
            plan_action(FinishUpload, repository, :generate_metadata => true)
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
