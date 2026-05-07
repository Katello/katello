module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        CACHE_KEY = 'katello/candlepin_status_response'.freeze
        CACHE_TTL = 180.seconds
        RACE_TTL = 3.seconds

        class << self
          def ping(try_cache: false)
            Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, race_condition_ttl: RACE_TTL, force: !try_cache) do
              response = get('/candlepin/status').body
              JSON.parse(response).with_indifferent_access
            end
          end

          def ok?
            ping(try_cache: true)['mode'] == 'NORMAL'
          end

          def clear_cache
            Rails.cache.delete(CACHE_KEY)
          end
        end
      end
    end
  end
end
