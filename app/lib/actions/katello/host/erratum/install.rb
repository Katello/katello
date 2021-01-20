module Actions
  module Katello
    module Host
      module Erratum
        class Install < Actions::Katello::AgentAction
          def plan(host, errata_ids)
            Type! host, ::Host::Managed

            action_subject(host, :hostname => host.name, :errata => errata_ids)

            plan_self(:host_id => host.id, errata_ids: errata_ids)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :install_errata,
              host_id: input[:host_id],
              errata_ids: input[:errata_ids]
            )
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
            [input[:errata].join(", ")] + super
          end

          def resource_locks
            :link
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of errata requested: %{errata}") % {errata: input[:errata].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
