module Actions
  module Pulp3
    module CapsuleContent
      class RefreshContentGuard < Pulp3::AbstractAsyncTask
        def plan(smart_proxy, options = {})
          content_guard_api = ::Katello::Pulp3::Api::ContentGuard.new(smart_proxy)
          content_guard_href = content_guard_api.list&.results&.first&.pulp_href
          if content_guard_href && options.try(:[], :update)
            content_guard_api.partial_update content_guard_href
          else
            content_guard_api.create
          end
        end
      end
    end
  end
end
