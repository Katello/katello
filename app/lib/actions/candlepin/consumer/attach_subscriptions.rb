module Actions
  module Candlepin
    module Consumer
      class AttachSubscriptions < Candlepin::Abstract
        input_format do
          param :uuid, String
          param :subscriptions, Hash
        end

        def plan(system, subscriptions)
          plan_self(:uuid => system.uuid, :subscriptions => subscriptions)
        end

        def run
          output[:results] = []
          if input[:subscriptions]
            input[:subscriptions].each do |subscription|
              output[:results] << ::Katello::Resources::Candlepin::Consumer.consume_entitlement(input[:uuid],
                  subscription[:id], subscription[:quantity])
            end
          end
        end
      end
    end
  end
end
