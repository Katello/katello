module Katello
  class UpstreamPool < OpenStruct
    CP_POOL = Resources::Candlepin::UpstreamPool

    class << self
      def fetch_pools(params)
        quantities_only = ::Foreman::Cast.to_bool(params.delete(:quantities_only))
        pool_id_map = Katello::Candlepin::PoolService.upstream_pool_id_map(params.delete(:pool_ids))

        cp_params = request_params(
          base_params: base_params(params),
          extra_params: pool_id_params(pool_id_map.keys),
          included_fields: included_field_params(quantities_only)
        )

        upstream_response = CP_POOL.get(params: cp_params)
        pools = response_to_pools(upstream_response, pool_id_map: pool_id_map)
        total = upstream_response.headers[total_count_header] || pools.count

        respond(pools, total)
      end

      def respond(pools, total)
        {
          pools: pools,
          total: total,
          subtotal: pools.count,
        }
      end

      def base_params(params)
        attachable = ::Foreman::Cast.to_bool(params.delete(:attachable))
        params[:consumer] = upstream_consumer_id if attachable
        params[:sort_by] = 'Product.name'
        params[:order] = 'asc'
        params
      end

      def upstream_consumer_id
        CP_POOL.upstream_consumer_id
      end

      def response_to_pools(response, pool_id_map: {})
        pools = JSON.parse(response)
        if pool_id_map.empty?
          pool_id_map = Katello::Candlepin::PoolService.map_upstream_pools_to_local(pools)
        end
        pools.map { |pool| self.new(map_attributes(pool, pool_id_map: pool_id_map)) }
      end

      def kat_to_cp_map
        {
          id: 'id',
          active: 'activeSubscription',
          quantity: 'quantity',
          start_date: 'startDate',
          end_date: 'endDate',
          contract_number: 'contractNumber',
          consumed: 'consumed',
          product_name: 'productName',
          product_id: 'productId',
          subscription_id: 'subscriptionId',
        }
      end

      def map_attributes(pool, pool_id_map: {})
        attributes = {}
        kat_to_cp_map.map do |kat, cp|
          attributes[kat] = pool[cp] if pool[cp]
        end

        attributes[:local_pool_ids] = pool_id_map[attributes[:id]]

        attributes
      end

      def minimal_fields
        kat_to_cp_map.values_at(:id, :quantity)
      end

      def all_fields
        kat_to_cp_map.values
      end

      def request_params(base_params: {}, extra_params: [], included_fields: [])
        # use extra_params when you have duplicate keys
        # i.e. [[:michael, "bolton"], [:michael, "jordan"]]
        included_fields.map! { |field| [:include, field] }
        RestClient::ParamsArray.new(base_params.to_a + extra_params + included_fields)
      end

      def pool_id_params(pool_ids)
        pool_ids ? pool_ids.map { |pool| [:poolid, pool] } : []
      end

      def included_field_params(quantities_only)
        quantities_only ? minimal_fields : all_fields
      end

      def total_count_header
        Katello::Resources::Candlepin::TOTAL_COUNT_HEADER
      end
    end

    def available
      return -1 if self.quantity == -1
      return 0 unless self.quantity && self.consumed
      self.quantity - self.consumed
    end
  end
end
