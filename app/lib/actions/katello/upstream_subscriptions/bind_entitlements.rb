module Actions
  module Katello
    module UpstreamSubscriptions
      class BindEntitlements < Actions::Base
        def plan(pools = [])
          fail _("No pools were provided.") unless pools.any?
          fail _("Current organization is not set.") unless ::Organization.current
          input[:pools] = pools

          sequence do
            concurrence do
              pools.each do |pool|
                plan_action(Katello::UpstreamSubscriptions::BindEntitlement, pool)
              end
            end
            plan_action(Katello::Organization::ManifestRefresh, ::Organization.current)
          end
        end

        def humanized_name
          N_("Bind entitlements to an allocation")
        end
      end
    end
  end
end
