module Actions
  module Katello
    module ContentView
      class CapsuleSync < Actions::Base
        def humanized_name
          _("Sync Content View on Smart Proxy(ies)")
        end

        def plan(content_view, environment)
          sequence do
            concurrence do
              smart_proxies = SmartProxy.unscoped.with_environment(environment).select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) }
              unless smart_proxies.blank?
                plan_action(::Actions::BulkAction, ::Actions::Katello::CapsuleContent::Sync, smart_proxies.sort,
                            :content_view_id => content_view.id, :environment_id => environment.id)
              end
            end
          end
        end
      end
    end
  end
end
