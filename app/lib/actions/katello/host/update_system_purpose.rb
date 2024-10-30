module Actions
  module Katello
    module Host
      class UpdateSystemPurpose < Actions::EntryAction
        def plan(host, service_level, purpose_role, purpose_usage)
          fail _("Host %s has not been registered with subscription-manager.") % host.name unless host.subscription_facet

          host.subscription_facet.service_level = service_level unless service_level.nil?
          host.subscription_facet.purpose_role = purpose_role unless purpose_role.nil?
          host.subscription_facet.purpose_usage = purpose_usage unless purpose_usage.nil?

          host.save!
          plan_self(:hostname => host.name)
        end

        def humanized_name
          if input&.dig(:hostname)
            _("Updating System Purpose for host %s") % input[:hostname]
          else
            _("Updating System Purpose for host")
          end
        end
      end
    end
  end
end
