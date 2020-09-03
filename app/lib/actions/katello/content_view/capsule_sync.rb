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
              smart_proxies = SmartProxy.with_environment(environment)
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
