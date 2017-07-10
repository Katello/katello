module Actions
  module Katello
    module Repository
      class CapsuleGenerateAndSync < Actions::Base
        def humanized_name
          _("Sync Repository on Smart Proxy(ies)")
        end

        def plan(repo)
          if repo.node_syncable?
            concurrence do
              smart_proxies = ::Katello::CapsuleContent.with_environment(repo.environment).map { |c| c.capsule }
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
