module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        class << self
          def ping
            response = get('/candlepin/status').body
            JSON.parse(response).with_indifferent_access
          end

          def distributor_versions
            response = get("/candlepin/distributor_versions").body
            JSON.parse(response)
          end
        end
      end
    end
  end
end
