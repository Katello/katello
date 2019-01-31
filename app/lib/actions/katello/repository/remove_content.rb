module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        include Dynflow::Action::WithSubPlans

        def plan(repository, content_units, options = {})
          sync_capsule = options.fetch(:sync_capsule, true)
          if repository.redhat?
            fail _("Cannot remove content from a non-custom repository")
          end
          unless repository.content_view.default?
            fail _("Can only remove content from within the Default Content View")
          end

          action_subject(repository)

          pulp_action = Pulp::Repository::RemoveUnits
          content_unit_ids = content_units.map(&:id)
          content_unit_type = content_units.first.class::CONTENT_TYPE

          sequence do
            plan_action(pulp_action, :repo_id => repository.id, :contents => content_unit_ids, :content_unit_type => content_unit_type)
            plan_self(:content_unit_class => content_units.first.class.name, :content_unit_ids => content_unit_ids)
            plan_action(CapsuleSync, repository) if sync_capsule
          end
        end

        def create_sub_plans
          trigger(Actions::Katello::Repository::MetadataGenerate,
                  ::Katello::Repository.find(input[:repository][:id]))
        end

        def resource_locks
          :link
        end

        def finalize
          if (input[:content_unit_class] && input[:content_unit_ids])
            repo = ::Katello::Repository.find(input[:repository][:id])
            content_units = input[:content_unit_class].constantize.where(:id => input[:content_unit_ids])
            repo.remove_content(content_units)
          end
        end

        def humanized_name
          _("Remove Content")
        end
      end
    end
  end
end
