module Actions
  module Katello
    module UpstreamSubscriptions
      class BindEntitlement < Actions::Base
        def run
          output[:response] = ::Katello::Resources::Candlepin::UpstreamConsumer
            .bind_entitlement(**pool)
        end

        def humanized_name
          N_("Bind an entitlement to an allocation")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def pool
          {
            pool: input[:pool],
            quantity: input[:quantity]
          }
        end
      end
    end
  end
end
