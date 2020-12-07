module Actions
  module Middleware
    class RecordSmartProxySyncHistory < Dynflow::Middleware
      def save_smart_proxy_sync_history
        if (action.input[:repository_id] && (action.input[:smart_proxy_id] || action.input[:capsule_id]) && !self.action.output[:smart_proxy_history_id])
          repo_id = action.input[:repository_id]
          repo = ::Katello::Repository.find_by(id: repo_id)
          smart_proxy_id = action.input[:smart_proxy_id] || action.input[:capsule_id]
          smart_proxy = ::SmartProxy.find_by(id: smart_proxy_id)

          #skip pulp2 puppet syncs
          if (repo_pulp_id = action.input[:repo_pulp_id])
            return if ::Katello::ContentViewPuppetEnvironment.find_by(pulp_id: repo_pulp_id)
          end

          if repo && smart_proxy
            self.action.output[:smart_proxy_history_id] = repo.create_smart_proxy_sync_history(smart_proxy)
          else
            fail "Smart Proxy could not be found with id #{smart_proxy_id}" if smart_proxy.nil?
            fail "Repository could not be found with id #{repo_id}" if repo.nil?
          end
        end
      end

      def run(*args)
        begin
          save_smart_proxy_sync_history
        rescue => error
          Rails.logger.error("Error saving smart proxy history: #{error.message}")
        end
        pass(*args)
      end
    end
  end
end
