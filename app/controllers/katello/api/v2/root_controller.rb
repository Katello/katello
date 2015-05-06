module Katello
  class Api::V2::RootController < Api::V2::ApiController
    skip_before_filter :authorize # ok - only shows URLs available
    skip_before_filter :require_user

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def resource_list
      all_routes = Engine.routes.routes
      all_routes = all_routes.collect { |r| r.path.spec.to_s }

      api_root_routes = all_routes.select do |path|
        path =~ %r{^/katello/api(\(/:api_version\))?/[^/]+/:id\(\.:format\)$}
      end
      api_root_routes = api_root_routes.collect do |path|
        path = path.sub("(/:api_version)", "")
        path[0..-(":id(.:format)".length + 1)]
      end

      api_root_routes.collect! { |r| { :rel => r["/katello/api/".size..-2], :href => r } }

      # provide some fake paths that does not exist (but rhsm is checking it's existance)
      api_root_routes << { :href => '/katello/api/packages/', :rel => 'packages' }
      api_root_routes << { :href => '/katello/api/status/', :rel => 'status' }
      api_root_routes << { :href => '/katello/api/guestids', :rel => 'guestids'}
      api_root_routes << { :href => '/katello/api/content_overrides', :rel => 'content_overrides'}
      api_root_routes << { :href => '/katello/api/available_releases', :rel => 'available_releases'}

      respond_for_index :collection => api_root_routes
    end
  end
end
