module Actions
  module Katello
    module UpstreamSubscriptions
      class RemoveEntitlement < Actions::Base
        middleware.use Actions::Middleware::KeepCurrentTaxonomies
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        input_format do
          param :entitlement_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::UpstreamConsumer.remove_entitlement(input[:entitlement_id])
        end

        def run_progress_weight
          0.01
        end
      end
    end
  end
end
