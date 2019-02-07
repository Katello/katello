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
              smart_proxies = ::SmartProxy.with_environment(repo.environment)
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
