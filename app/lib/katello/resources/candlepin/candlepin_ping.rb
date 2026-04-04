module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        CACHE_KEY = 'katello/candlepin_status_response'.freeze
        CACHE_TTL = 60.seconds

        class << self
          # Fetch Candlepin status. By default always polls Candlepin live.
          # Pass try_cache: true to serve from cache when warm — used by
          # server_status and ok? during registration.
          def ping(try_cache: false)
            cache_miss = false
            result = Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, force: !try_cache) do
              cache_miss = true
              ::Foreman::Logging.logger('registration').debug "rhsm_status cache=MISS"
              response = get('/candlepin/status').body
              JSON.parse(response).with_indifferent_access
            end
            ::Foreman::Logging.logger('registration').debug "rhsm_status cache=HIT" unless cache_miss
            result
          end

          # Returns true if Candlepin is in NORMAL mode.
          # Uses the cache populated by server_status so the pre-flight check
          # is a free Redis read when the cache is warm. Falls back to a direct
          # Candlepin ping on a cold miss and writes the result to cache.
          def ok?
            ping(try_cache: true)['mode'] == 'NORMAL'
          end

          # Immediately invalidates the cached Candlepin status. Called on
          # registration failure so subsequent pre-flight checks detect the
          # outage rather than serving a stale "NORMAL" result.
          def clear_cache
            Rails.cache.delete(CACHE_KEY)
          end
        end
      end
    end
  end
end
