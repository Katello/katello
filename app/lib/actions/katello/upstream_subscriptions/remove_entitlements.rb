module Actions
  module Katello
    module UpstreamSubscriptions
      class RemoveEntitlements < Actions::Base
        def plan(pool_ids = [])
          ids = pool_ids.uniq.compact
          fail _("No pool IDs were provided.") if ids.blank?
          fail _("Current organization is not set.") unless ::Organization.current

          sequence do
            ids.each do |pid|
              pool = ::Katello::Pool.find(pid)

              fail _("Provided pool with id %s has no upstream entitlement" % pid) if pool.upstream_entitlement_id.nil?

              plan_action(::Actions::Katello::UpstreamSubscriptions::RemoveEntitlement, entitlement_id: pool.upstream_entitlement_id)
            end

            plan_action(::Actions::Katello::Organization::ManifestRefresh, ::Organization.current)
          end
        end

        def humanized_name
          N_("Delete Upstream Subscription")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
