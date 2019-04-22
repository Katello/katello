module Actions
  module Pulp3
    module Repository
      class Index < Pulp3::Abstract
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repo, smart_proxy, options)
          plan_self(:repo_id => repo.id, :smart_proxy_id => smart_proxy.id, :contents_changed => options[:contents_changed], :full_index => options[:full_index])
        end

        def run
          repo = ::Katello::Repository.find(input[:repo_id])
          repo.backend_service(::SmartProxy.find(input[:smart_proxy_id])).index_content(input.dig(:full_index) || false)
        end
      end
    end
  end
end
