require 'katello/resources/candlepin'

module Katello
  class UpstreamPool < OpenStruct
    CP_POOL = Resources::Candlepin::UpstreamPool

    class << self
      def fetch_pools(params)
        pools = JSON.parse(CP_POOL.get(params: cp_request_params.deep_merge(params)))
        pools.map { |pool| self.new(map_attributes(pool)) }
      end

      def map_attributes(pool)
        {
          pool_id: pool['id'],
          active: pool['activeSubscription'],
          quantity: pool['quantity'],
          start_date: pool['startDate'],
          end_date: pool['endDate'],
          contract_number: pool['contractNumber'],
          consumed: pool['consumed'],
          product_name: pool['productName'],
          product_id: pool['productId'],
          subscription_id: pool['subscriptionId']
        }
      end

      def cp_request_params
        { include: ['id',
                    'activeSubscription',
                    'quantity',
                    'startDate',
                    'endDate',
                    'contractNumber',
                    'consumed',
                    'productName',
                    'productId',
                    'subscriptionId'] }
      end
    end
  end
end
