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
        end
      end
    end
  end
end
