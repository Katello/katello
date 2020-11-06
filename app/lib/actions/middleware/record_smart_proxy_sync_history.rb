module Actions
  module Middleware
    class RecordSmartProxySyncHistory < Dynflow::Middleware
      def run(*args)
        if (action.input[:repository_id] && (action.input[:smart_proxy_id] || action.input[:capsule_id]) && !self.action.output[:smart_proxy_history_id])
          repo = ::Katello::Repository.find(action.input[:repository_id])
          smart_proxy_id = action.input[:smart_proxy_id] || action.input[:capsule_id]
          smart_proxy = ::SmartProxy.find(smart_proxy_id)
          self.action.output[:smart_proxy_history_id] = repo.create_smart_proxy_sync_history(smart_proxy)
        end
        pass(*args)
      end
    end
  end
end
