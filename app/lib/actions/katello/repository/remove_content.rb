module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        include Dynflow::Action::WithSubPlans
        include Actions::Katello::PulpSelector

        def plan(repository, content_units, options = {})
          sync_capsule = options.fetch(:sync_capsule, true)
          if repository.redhat?
            fail _("Cannot remove content from a non-custom repository")
          end
          unless repository.content_view.default?
            fail _("Can only remove content from within the Default Content View")
          end

          action_subject(repository)

          content_unit_ids = content_units.map(&:id)
          content_unit_type = options[:content_type] || content_units.first.class::CONTENT_TYPE

          sequence do
            remove_content_args = {
              :contents => content_unit_ids,
              :content_unit_type => content_unit_type}

            pulp_action = plan_pulp_action(
              [Pulp::Orchestration::Repository::RemoveUnits,
               Pulp3::Orchestration::Repository::RemoveUnits],
              repository, SmartProxy.pulp_primary, remove_content_args)
            return if pulp_action.error
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
            content_units = input[:content_unit_class].constantize.where(:id => input[:content_unit_ids])
            content_units.each do |content_unit|
              content_unit.remove_from_repository(input[:repository][:id])
            end
          end
        end

        def humanized_name
          _("Remove Content")
        end
      end
    end
  end
end
