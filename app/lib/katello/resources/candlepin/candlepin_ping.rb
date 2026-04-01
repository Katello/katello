module Katello
  module Resources
    module Candlepin
      class CandlepinPing < CandlepinResource
        CACHE_KEY = 'katello/candlepin_status_response'.freeze
        CACHE_TTL = 30.seconds

        class << self
          # Fetch Candlepin status. By default always polls Candlepin live,
          # preserving backward-compatible behaviour for callers such as
          # /api/v2/ping that must never return a cached result.
          # Pass try_cache: true to serve from cache when warm and only fall
          # back to Candlepin on a cold miss — used by server_status and ok?.
          def ping(try_cache: false)
            Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, force: !try_cache) do
              response = get('/candlepin/status').body
              JSON.parse(response).with_indifferent_access
            end
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
