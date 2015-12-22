module Actions
  module Candlepin
    module Consumer
      class Update < Candlepin::Abstract
        def plan(uuid, consumer_params)
          plan_self(:uuid => uuid,
                    :consumer_params => consumer_params)
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.update(input[:uuid], input[:consumer_params])
        end
      end
    end
  end
end
