module Actions
  module Katello
    module Host
      module PackageGroup
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, groups)
            Type! host, ::Host::Managed

            action_subject(host, :groups => groups)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: host.content_facet.uuid,
                        type:          'package_group',
                        args:          groups)
            plan_self(:host_id => host.id)
          end

          def humanized_name
            _("Install package group")
          end

          def humanized_input
            [input[:groups].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of package group(s) requested: %{groups}") % {groups: input[:groups].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
