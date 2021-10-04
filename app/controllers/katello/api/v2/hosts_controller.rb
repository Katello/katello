module Katello
  class Api::V2::HostsController < Api::V2::ApiController
    include ::Foreman::Renderer::Scope::Macros::Base

    before_action :find_smart_proxy,
                  :find_organization,
                  :find_location,
                  :find_hostgroup,
                  :api_auth_token,
                  :template_vars

    rescue_from ActiveRecord::RecordNotFound do |error|
      logger.info "#{error.message} (#{error.class})"
      not_found(error.message)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render_error(error.message, status: :unprocessable_entity)
    end

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/change_proxy", N_("Generate bash code for host migration to proxy")
    param :organization_id, :number, desc: N_("Organization ID. If no ID is set, the default organization of the user is assumed.")
    param :location_id, :number, desc: N_("Location ID")
    param :smart_proxy_id, String, required: true, :desc => N_("Smart Proxy ID")
    param :hostgroup_id, :number, required: false, desc: N_("Host group ID")
    def change_proxy
    end

    private

    def find_smart_proxy
      @smart_proxy = SmartProxy.authorized(:view_smart_proxies).find(params[:smart_proxy_id])
      render_error('Pulp 3 is not enabled on Smart proxy!') and return unless @smart_proxy.pulp3_enabled?
    end

    def find_organization
      from_param = Organization.authorized(:view_organizations).find(params['organization_id']) if params['organization_id'].present?
      @organization = from_param || User.current.default_organization || User.current.my_organizations.first
    end

    def find_location
      return unless params[:location_id]
      @location = ::Location.authorized(:view_locations).find(params[:location_id])
    end

    def find_hostgroup
      return unless params[:hostgroup_id]
      @hostgroup = ::Hostgroup.authorized(:view_hostgroups).find(params[:hostgroup_id])
    end

    def api_auth_token
      scope = [{
        controller: :hosts,
        actions: [:update]
      }]

      @auth_token = User.current.jwt_token!(expiration: 4.hours.to_i, scope: scope)
    end

    def template_vars
      @ca_cert = foreman_server_ca_cert
      @rhsm_url = URI(@smart_proxy.rhsm_url)
      @pulp_content_url = @smart_proxy.setting(SmartProxy::PULP3_FEATURE, 'content_app_url')
      @activation_keys = Shellwords.shellescape(params[:activation_keys])
      @host_api_url = "#{Setting[:foreman_url]}/api/hosts"
      @host_params = { host: host_update_params.compact }
    end

    def host_update_params
      {
        location_id: @location&.id,
        hostgroup_id: @hostgroup&.id,
        content_facet_attributes: {
          content_source_id: @smart_proxy.id
        },
        content_source_id: @smart_proxy.id,
        openscap_proxy_id: (@smart_proxy.id if @smart_proxy.features.find_by(name: "Openscap"))
      }
    end

    def render_error(error, options = {})
      locals_exception = options&.dig(:locals, :exception)
      locals_message = options&.dig(:locals, :message)
      status = options[:status] || :unprocessable_entity

      output = <<~ERROR
        echo "ERROR: #{error}";
        #{"echo \"#{locals_exception}\";" if locals_exception}
        #{"echo \"#{locals_message}\";" if locals_message}
        exit 1
      ERROR

      render plain: output.squeeze("\n"), status: status
    end

    def not_found(options = nil)
      nf_opts = { locals: {} }
      nf_opts[:status] = :not_found

      case options
      when String
        nf_opts[:locals][:message] = options
      when Hash
        nf_opts[:locals].merge! options
      else
        render_error 'not_found', nf_opts
        return false
      end

      render_error 'not_found', nf_opts

      false
    end
  end
end
