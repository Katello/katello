module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        class << self
          def ping
            response = get('/candlepin/status').body
            JSON.parse(response).with_indifferent_access
          end
        end
      end
    end
  end
end
