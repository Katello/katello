module Katello
  module Events
    class DeletePool
      EVENT_TYPE = 'delete_pool'.freeze

      def initialize(pool_id)
        @pool_id = pool_id
      end

      def run
        if ::Katello::Pool.where(id: @pool_id).destroy_all.any?
          Rails.logger.info("Deleted pool #{@pool_id}")
        else
          Rails.logger.info("Pool with id=#{@pool_id} has already been removed")
        end
      end
    end
  end
end
