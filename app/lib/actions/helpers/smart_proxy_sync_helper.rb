module Actions
  module Helpers
    module SmartProxySyncHelper
      def schedule_async_repository_proxy_sync(repository)
        return unless Setting[:foreman_proxy_content_auto_sync]
        if SmartProxy.unscoped.pulpcore_proxies_with_environment(repository.environment).exists?
          ForemanTasks.async_task(::Actions::Katello::Repository::CapsuleSync, repository)
        end
      end
    end
  end
end
