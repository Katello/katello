module Katello
  module Candlepin
    class PoolService
      def self.local_to_upstream_ids(local_pool_ids)
        pools = Katello::Pool.find(local_pool_ids)
        id_map = Hash.new { |hash, key| hash[key] = [] }

        pools.each do |pool|
          fail 'No upstream pool ID was found for Katello::Pool with ID: %s' % pool.id unless pool.upstream_pool_id
          id_map[pool.upstream_pool_id] << pool.id
        end

        id_map
      end
    end
  end
end
