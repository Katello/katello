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
        end
      end
    end
  end
end
