module Actions
  module Katello
    module Host
      module PackageGroup
        class Remove < Actions::Katello::AgentAction
          def self.agent_message
            :remove_package_group
          end

          def agent_action_type
            :content_uninstall
          end

          def humanized_name
            _("Remove package group")
          end

          def humanized_input
            [input[:content].join(', ')] + super
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Removal of package group(s) requested: %{groups}") % {groups: input[:content].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
