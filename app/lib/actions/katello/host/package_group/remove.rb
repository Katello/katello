module Actions
  module Katello
    module Host
      module PackageGroup
        class Remove < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, groups)
            action_subject(host, :groups => groups)
            plan_action(Pulp::Consumer::ContentUninstall,
                        consumer_uuid: host.content_facet.uuid,
                        type:          'package_group',
                        args:          groups)
            plan_self(:host_id => host.id)
          end

          def humanized_name
            _("Remove package group")
          end

          def humanized_input
            [input[:groups].join(', ')] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(
                self, planned_actions(Pulp::Consumer::ContentUninstall))
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: _("Removal of package group(s) requested: %{groups}") % {groups: input[:groups].join(", ")})
          end
        end
      end
    end
  end
end
