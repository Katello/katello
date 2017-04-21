module Katello
  module Events
    class ImportPool
      EVENT_TYPE = 'import_pool'.freeze

      def initialize(pool_id)
        @pool = ::Katello::Pool.find_by(:id => pool_id)
      end

      def run
        @pool.try(:import_data)
      rescue RestClient::ResourceNotFound
        Rails.logger.warn "skipped re-index of non-existent pool #{@pool.cp_id}"
      end
    end
  end
end
