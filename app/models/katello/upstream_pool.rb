module Katello
  class UpstreamPool < OpenStruct
    CP_POOL = Resources::Candlepin::UpstreamPool

    class << self
      def fetch_pools(params)
        quantities_only = ::Foreman::Cast.to_bool(params.delete("quantities_only"))
        cp_params = request_params(
          base_params: params,
          extra_params: pool_id_params(params.delete("pool_ids")),
          included_fields: included_field_params(quantities_only)
        )

        response = CP_POOL.get(params: cp_params)
        pools = response_to_pools(response)

        {
          pools: pools,
          total: response.headers[total_count_header] || pools.count
        }
      end

      def response_to_pools(response)
        pools = JSON.parse(response)
        pools.map { |pool| self.new(map_attributes(pool)) }
      end

      def kat_to_cp_map
        {
          pool_id: 'id',
          active: 'activeSubscription',
          quantity: 'quantity',
          start_date: 'startDate',
          end_date: 'endDate',
          contract_number: 'contractNumber',
          consumed: 'consumed',
          product_name: 'productName',
          product_id: 'productId',
          subscription_id: 'subscriptionId'
        }
      end

      def map_attributes(pool)
        attributes = {}
        kat_to_cp_map.map do |kat, cp|
          attributes[kat] = pool[cp] if pool[cp]
        end
        attributes
      end

      def minimal_fields
        kat_to_cp_map.values_at(:pool_id, :quantity)
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
  end
end
