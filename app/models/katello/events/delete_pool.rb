module Katello
  module Events
    class DeletePool
      EVENT_TYPE = 'delete_pool'.freeze

      def initialize(candlepin_id)
        @candlepin_id = candlepin_id
      end

      def run
        if ::Katello::Pool.where(id: @candlepin_id).destroy_all.any?
          Rails.logger.info("Deleted pool #{@candlepin_id}")
        else
          Rails.logger.info("Pool with id=#{@candlepin_id} has already been removed")
        end
      end
    end
  end
end
