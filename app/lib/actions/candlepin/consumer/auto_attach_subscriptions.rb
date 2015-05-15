module Actions
  module Candlepin
    module Consumer
      class AutoAttachSubscriptions < Candlepin::Abstract
        input_format do
          param :uuid, String
        end

        def plan(system)
          plan_self(:uuid => system.uuid)
        end

        def run
          output[:attached_subscriptions] = ::Katello::Resources::Candlepin::Consumer.refresh_entitlements(input[:uuid])
        end
      end
    end
  end
end
