module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        CACHE_KEY = 'katello/candlepin_status_response'.freeze
        CACHE_TTL = 180.seconds
        RACE_TTL = 3.seconds

        class << self
          def ping(try_cache: false)
            cache_miss = false
            result = Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, race_condition_ttl: RACE_TTL, force: !try_cache) do
              cache_miss = true
              ::Foreman::Logging.logger('registration').debug "rhsm_status cache=MISS"
              response = get('/candlepin/status').body
              JSON.parse(response).with_indifferent_access
            end
            ::Foreman::Logging.logger('registration').debug "rhsm_status cache=HIT" unless cache_miss || !try_cache
            result
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
