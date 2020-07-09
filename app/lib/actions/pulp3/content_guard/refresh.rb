module Actions
  module Pulp3
    module ContentGuard
      class Refresh < Pulp3::Abstract
        def plan(smart_proxy, options = {})
          return if (::Katello::Pulp3::ContentGuard.count > 0 || options.try(:[], :update))
          content_guard_api = ::Katello::Pulp3::Api::ContentGuard.new(smart_proxy)
          if options.try(:[], :update)
            content_guard_href = ::Katello::Pulp3::ContentGuard.first.href
            content_guard_api.partial_update content_guard_href
          else
            content_guard_api.create
            ::Katello::Pulp3::ContentGuard.import(smart_proxy)
          end
        end
      end
    end
  end
end
