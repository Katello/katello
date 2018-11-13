module Actions
  module Katello
    module Host
      module Package
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, packages)
            Type! host, ::Host::Managed

            action_subject(host, :packages => packages)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: host.content_facet.uuid,
                        type:          'rpm',
                        args:          packages)
            plan_self(:host_id => host.id)
          end

          def humanized_name
            _("Install package")
          end

          def humanized_input
            [input[:packages].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: _("Installation of package(s) requested: %{packages}") % {packages: input[:packages].join(", ")})
          end
        end
      end
    end
  end
end
