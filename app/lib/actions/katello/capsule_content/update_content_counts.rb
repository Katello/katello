module Actions
  module Katello
    module CapsuleContent
      class UpdateContentCounts < Actions::EntryAction
        def plan(smart_proxy)
          plan_self(:smart_proxy_id => smart_proxy.id)
        end

        def humanized_name
          _("Update Content Counts")
        end

        def run
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          smart_proxy.update_content_counts!
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
