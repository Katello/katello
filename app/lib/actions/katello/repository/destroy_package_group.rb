module Actions
  module Katello
    module Repository
      class DestroyPackageGroup < Actions::EntryAction
        def plan(repository, pkg_group_id)
          action_subject(repository)
          criteria = { type_ids: ["package_group"], filters: {"unit": {"name": pkg_group_id} } }

          sequence do
            # TODO: Replace with Pulp 3?
            fail 'Pulp 2 was used'
            plan_action(IndexPackageGroups, repository)
            plan_action(Katello::Repository::MetadataGenerate, repository)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Delete Package Group")
        end
      end
    end
  end
end
