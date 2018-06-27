module Katello
  module Candlepin
    class PoolService
      def self.upstream_pool_id_map(local_pool_ids, fail_on_not_found: true)
        return {} unless local_pool_ids

        local_to_upstream_ids(local_pool_ids, fail_on_not_found: fail_on_not_found)
      end

      def self.local_to_upstream_ids(local_pool_ids, fail_on_not_found: true)
        pools = Katello::Pool.where(id: local_pool_ids)
        id_map = Hash.new { |hash, key| hash[key] = [] }

        pools.each do |pool|
          if fail_on_not_found && !pool.upstream_pool_id
            fail 'No upstream pool ID was found for Katello::Pool with ID: %s' % pool.id
          end
          id_map[pool.upstream_pool_id] << pool.id
        end

        id_map
      end

      # For mapping the upstream pools after the candlepin request has returned them
      def self.map_upstream_pools_to_local(pools)
        upstream_pool_ids = pools.map { |x| x['id'] }
        local_pool_ids = Katello::Pool.where(upstream_pool_id: upstream_pool_ids).pluck(:id)
        return upstream_pool_id_map(local_pool_ids, fail_on_not_found: false)
      end
    end
  end
end
