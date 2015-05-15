module Actions
  module Candlepin
    module Consumer
      class UnattachSubscriptions < Candlepin::Abstract
        input_format do
          param :uuid, String
          param :entitlements, Array
        end

        def plan(system, subscriptions)
          entitlements = []
          subscriptions.each do |subscription|
            system.entitlements.each do |entitlement|
              if subscription[:id] == entitlement[:pool][:id]
                entitlements << entitlement[:id]
                break
              end
            end
          end
          plan_self(:uuid => system.uuid, :entitlements => entitlements)
        end

        def run
          output[:results] = []
          input[:entitlements].each do |entitlement|
            output[:results] << ::Katello::Resources::Candlepin::Consumer.remove_entitlement(input[:uuid], entitlement)
          end
        end
      end
    end
  end
end
