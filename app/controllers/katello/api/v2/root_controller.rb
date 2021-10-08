module Katello
  class Api::V2::RootController < Api::V2::ApiController
    skip_before_action :authorize # ok - only shows URLs available
    skip_before_action :load_settings # no Settings used here, avoid DB calls
    after_action :skip_session

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def resource_list
      render json: self.class.rhsm_resource_list
    end

    def rhsm_resource_list
      # The RHSM resource list is required to interact with RHSM on the client.
      # When requested, it will return a list of the resources (href & rel) defined by katello
      # for the /rhsm namespace.  The rel values are used by RHSM to determine if the server
      # supports a particular resource (e.g. environments, guestids, organizations..etc)

      render json: self.class.rhsm_resource_list
    end

    def self.resource_list
      @resource_list ||= generate_resource_list
    end

    def self.rhsm_resource_list
      @rhsm_resource_list ||= generate_rhsm_resource_list
    end

    def self.generate_resource_list
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
    end

    def self.generate_rhsm_resource_list
      all_routes = Engine.routes.routes.collect { |r| r.path.spec.to_s }

      api_routes = all_routes.select do |path|
        # obtain only the rhsm routes
        path =~ %r{^/rhsm/.+$}
      end

      api_routes = api_routes.collect do |path|
        # drop the trailing :format
        path = path.sub("(.:format)", "")

        # drop the trailing ids
        path_elements = path.split("/")
        if path_elements.last.start_with?(':') && path_elements.last.end_with?('id')
          path_elements.delete_at(-1)
          path_elements.join('/')
        else
          path
        end
      end

      api_routes.uniq!
      api_routes.collect! { |r| { :rel => r.split('/').last, :href => r } }
    end
  end
end
