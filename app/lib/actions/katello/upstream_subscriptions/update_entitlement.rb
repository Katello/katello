module Actions
  module Katello
    module UpstreamSubscriptions
      class UpdateEntitlement < Actions::Base
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        input_format do
          param :entitlement_id
          param :quantity
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::UpstreamEntitlement.update(input[:entitlement_id], input[:quantity])
        end

        def run_progress_weight
          0.01
        end
      end
    end
  end
end
