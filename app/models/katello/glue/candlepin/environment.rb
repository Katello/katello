require 'set'

module Katello
  module Glue::Candlepin::Environment
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def candlepin_info
        Resources::Candlepin::Environment.find(self.cp_id)
      end

      def exists_in_candlepin?
        candlepin_info
        true
      rescue RestClient::NotFound
        false
      end

      def content_ids
        self.candlepin_info['environmentContent'].collect { |c| c['id'] }
      end
    end
  end
end
