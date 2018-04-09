module Actions
  module Katello
    module UpstreamSubscriptions
      class UpdateEntitlements < Actions::Base
        middleware.use Actions::Middleware::KeepCurrentTaxonomies

        def plan(pools = [])
          fail _("No pools were provided.") if pools.blank?
          fail _("Current organization is not set.") unless ::Organization.current

          sequence do
            concurrence do
              pools.each do |p|
                pool = ::Katello::Pool.find(p[:id])

                fail _("Provided pool with id %s has no upstream entitlement" % p[:id]) if pool.upstream_entitlement_id.nil?
                plan_action(::Actions::Katello::UpstreamSubscriptions::UpdateEntitlement,
                            entitlement_id: pool.upstream_entitlement_id,
                            quantity: p[:quantity])
              end
            end

            plan_action(::Actions::Katello::Organization::ManifestRefresh, ::Organization.current)
          end
        end

        def humanized_name
          N_("Update Upstream Subscription")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
