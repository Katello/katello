module Actions
  module Katello
    module Host
      module Erratum
        class Install < Actions::Katello::AgentAction
          def self.agent_message
            :install_errata
          end

          def agent_action_type
            :content_install
          end

          def humanized_name
            if input.try(:[], :hostname)
              _("Install erratum for %s") % input[:hostname]
            else
              _("Install erratum")
            end
          end

          def humanized_input
            [input[:content].join(", ")] + super
          end

          def resource_locks
            :link
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of errata requested: %{errata}") % {errata: input[:content].join(", ")}).truncate(255))
          end

          def self.cleanup_after
            '90d'
          end
        end
      end
    end
  end
end
