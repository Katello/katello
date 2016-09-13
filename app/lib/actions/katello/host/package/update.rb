module Actions
  module Katello
    module Host
      module Package
        class Update < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, packages)
            Type! host, ::Host::Managed

            action_subject(host, :packages => packages)
            plan_action(Pulp::Consumer::ContentUpdate,
                        consumer_uuid: host.content_facet.uuid,
                        type:          'rpm',
                        args:          packages)
          end

          def humanized_name
            _("Update package")
          end

          def humanized_input
            [input[:packages].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentUpdate))
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end
        end
      end
    end
  end
end
