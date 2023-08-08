module Actions
  module Katello
    module Repository
      class CapsuleSync < Actions::Base
        def humanized_name
          _("Sync Repository on Smart Proxy(ies)")
        end

        def plan(repo)
          if repo.node_syncable?
            concurrence do
              smart_proxies = ::SmartProxy.unscoped.with_environment(repo.environment).select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) }
              unless smart_proxies.blank?
                plan_action(::Actions::BulkAction, ::Actions::Katello::CapsuleContent::Sync, smart_proxies,
                            :repository_id => repo.id)
              end
            end
          end
        end
      end
    end
  end
end
