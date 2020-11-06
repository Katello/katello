module Actions
  module Helpers
    module SmartProxySyncHistoryHelper
      def self.included(base)
        base.middleware.use ::Actions::Middleware::RecordSmartProxySyncHistory
      end

      def done?
        is_done = super
        if is_done
          ::Katello::SmartProxySyncHistory.where(:id => output[:smart_proxy_history_id], :finished_at => nil).update_all(finished_at: Time.now)
        end
        is_done
      end

      def rescue_external_task(error)
        if output[:smart_proxy_history_id]
          ::Katello::SmartProxySyncHistory.where(:id => output[:smart_proxy_history_id], :finished_at => nil).delete_all
        end
        super
      end
    end
  end
end
