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
              env_smart_proxies = SmartProxy.unscoped.with_environment(repo.environment)
              smart_proxies = env_smart_proxies.select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) }
              unless smart_proxies.blank?
                plan_action(::Actions::BulkAction, ::Actions::Katello::CapsuleContent::Sync, smart_proxies,
                            :repository_id => repo.id)
              end
              plan_self(environment_id: repo.environment.id, skipped_capsules: (env_smart_proxies - smart_proxies).any?)
            end
          end
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          if input[:skipped_capsules]
            output[:warning] = "Some smart proxies are not authorized for capsule content management or viewing in environment '#{environment.name}'. Skipping sync for those smart proxies."
            Rails.logger.warn output[:warning]
          end
        end
      end
    end
  end
end
