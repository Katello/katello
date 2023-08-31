module Katello
  # rubocop:disable Metrics/ClassLength
  class Api::Rhsm::CandlepinProxiesController < Api::V2::ApiController
    include Katello::Authentication::ClientAuthentication

    IF_MODIFIED_SINCE_HEADER = 'If-Modified-Since'.freeze

    before_action :disable_strong_params

    wrap_parameters false

    around_action :repackage_message
    before_action :find_host, :only => [:consumer_show, :consumer_destroy, :consumer_checkin, :enabled_repos,
                                        :regenerate_identity_certificates, :facts,
                                        :available_releases, :serials, :upload_tracer_profile]
    before_action :authorize, :only => [:consumer_create, :list_owners, :rhsm_index]
    before_action :authorize_client_or_user, :only => [:consumer_show, :regenerate_identity_certificates, :upload_tracer_profile, :facts, :proxy_jobs_get_path]
    before_action :authorize_client_or_admin, :only => [:hypervisors_update, :async_hypervisors_update, :hypervisors_heartbeat]
    before_action :authorize_proxy_routes, :only => [:get, :post, :put, :delete]
    before_action :authorize_client, :only => [:consumer_destroy, :consumer_checkin,
                                               :enabled_repos, :available_releases]

    before_action :check_registration_services, :only => [:consumer_create, :consumer_destroy, :consumer_activate]

    before_action :add_candlepin_version_header

    before_action :proxy_request_path, :proxy_request_body
    before_action :set_organization_id, :except => [:hypervisors_update, :async_hypervisors_update]
    before_action :find_hypervisor_organization, :only => [:async_hypervisors_update, :hypervisors_update]

    before_action :check_media_type, :except => :async_hypervisors_update

    prepend_before_action :convert_owner_to_organization_id, :except => [:hypervisors_update, :async_hypervisors_update], :if => lambda { params.key?(:owner) }
    prepend_before_action :convert_organization_label_to_id, :only => [:rhsm_index, :consumer_activate, :consumer_create], :if => lambda { params.key?(:organization_id) }

    def repackage_message
      yield
    ensure
      if response.status >= 400
        begin
          body_json = JSON.parse(response.body)
          if body_json['message'] && body_json['displayMessage'].nil?
            body_json['displayMessage'] = body_json['message']
          end
          response.body = body_json.to_s
        rescue JSON::ParserError
          # Not a json response, leave as-is
        end
      end
    end

    rescue_from RestClient::Exception do |e|
      Rails.logger.error(pp_exception(e, with_backtrace: false))
      Rails.logger.error(e.backtrace.detect { |line| line.match("katello.*controller") })
      if request_from_katello_cli?
        render :json => { :errors => [e.http_body] }, :status => e.http_code
      else
        render :plain => e.http_body, :status => e.http_code
      end
    end

    def proxy_request_path
      @request_path = drop_api_namespace(@_request.fullpath)
    end

    def proxy_request_body
      @request_body = @_request.body
    end

    def drop_api_namespace(original_request_path)
      prefix = "/rhsm"
      original_request_path.gsub(prefix, '')
    end

    def get
      extra_headers = {}
      modified_since = request.headers[IF_MODIFIED_SINCE_HEADER]
      if modified_since.present?
        extra_headers[IF_MODIFIED_SINCE_HEADER] = modified_since
      end

      r = Resources::Candlepin::Proxy.get(@request_path, extra_headers)
      logger.debug filter_sensitive_data(r)
      render :json => r, :status => r.code
    end

    def delete
      r = Resources::Candlepin::Proxy.delete(@request_path, @request_body.read)
      logger.debug filter_sensitive_data(r)
      render :json => r
    end

    def post
      r = Resources::Candlepin::Proxy.post(@request_path, @request_body.read)
      logger.debug filter_sensitive_data(r)
      render :json => r
    end

    def put
      r = Resources::Candlepin::Proxy.put(@request_path, @request_body.read)
      logger.debug filter_sensitive_data(r)
      render :json => r
    end

    #api :GET, "/consumers/:id", N_("Show a system")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def consumer_show
      render :json => Resources::Candlepin::Consumer.get(params[:id])
    end

    #api :GET, "/owners/:organization_id/environments", N_("List environments for RHSM")
    def rhsm_index
      @all_environments = get_content_view_environments(params[:name], Organization.current).collect do |env|
        {
          :id => env.cp_id,
          :name => env.label,
          :display_name => env.name,
          :description => env.content_view.description
        }
      end

      respond_for_index :collection => @all_environments
    end

    #api :POST, "/hypervisors/OWNER"
    # Note that this request comes in as content-type 'text/plain' so that
    # tomcat won't parse the json.  Here we just pass the plain body through to candlepin
    def async_hypervisors_update
      task = Katello::Resources::Candlepin::Consumer.async_hypervisors(owner: params[:owner],
                                                                       reporter_id: params[:reporter_id],
                                                                       raw_json: request.raw_post)
      async_task(::Actions::Katello::Host::Hypervisors, nil, :task_id => task['id'])

      render :json => task
    end

    #api :POST, "/hypervisors", N_("Update the hypervisors information for environment")
    #desc 'See virt-who tool for more details.'
    def hypervisors_update
      login = User.consumer? ? User.anonymous_api_admin.login : User.current.login
      task = User.as(login) do
        params['owner'] = @organization.label #override owner label if
        params['env'] = nil #hypervisors don't need an environment
        sync_task(::Actions::Katello::Host::Hypervisors, params.except(:controller, :action, :format).to_h)
      end
      render :json => task.output[:results]
    end

    def hypervisors_heartbeat
      render json: Katello::Resources::Candlepin::Consumer.hypervisors_heartbeat(owner: params[:owner], reporter_id: params[:reporter_id])
    end

    #api :PUT, "/consumers/:id/checkin/", N_("Update consumer check-in time")
    #param :date, String, :desc => N_("check-in time")
    def consumer_checkin
      @host.update(:last_checkin => params[:date])
      Candlepin::Consumer.new(@host.subscription_facet.uuid, @host.organization.label).checkin(params[:date])
      render :json => Resources::Candlepin::Consumer.get(@host.subscription_facet.uuid)
    end

    api :PUT, "/consumers/:id/tracer", N_("Update services requiring restart")
    param :traces, Hash, :required => true
    def upload_tracer_profile
      User.as_anonymous_admin do
        @host.import_tracer_profile(params[:traces])
      end
      render json: { displayMessage: _("Tracer profile uploaded successfully") }
    end

    def available_releases
      render :json => @host.content_facet.try(:available_releases) || []
    end

    def list_owners
      orgs = User.current.allowed_organizations
      # rhsm expects owner (Candlepin format)
      respond_for_index :collection => orgs.map { |o| { :key => o.label, :displayName => o.name } }
    end

    #api :POST, "/consumers/:id", N_("Regenerate consumer identity")
    #param :id, String, :desc => N_("UUID of the consumer")
    #desc 'Schedules the consumer identity certificate regeneration'
    def regenerate_identity_certificates
      uuid = @host.subscription_facet.uuid
      Candlepin::Consumer.new(uuid, @host.organization.label).regenerate_identity_certificates
      render :json => Resources::Candlepin::Consumer.get(uuid)
    end

    api :PUT, "/systems/:id/enabled_repos", N_("Update the information about enabled repositories")
    desc <<-DESC
      Used to keep the information about enabled repositories up to date.
      This information is then used for computing the errata available for the system.
    DESC
    param :enabled_repos, Hash, :required => true do
      param :repos, Array, :required => true do
        param :baseurl, Array, :desc => N_("List of enabled repo urls for the repo (Only first is used.)"), :required => false
      end
    end
    param :id, String, :desc => N_("UUID of the system"), :required => true
    def enabled_repos
      repos_params = params.dig('enabled_repos', 'repos')
      fail(HttpErrors::BadRequest, _("The request did not contain any repository information.")) if repos_params.nil?

      result = nil
      User.as_anonymous_admin do
        result = @host.import_enabled_repositories(repos_params)
      end

      respond_for_show :resource => result
    end

    #api :POST, "/environments/:environment_id/consumers", N_("Register a consumer in environment")
    def consumer_create
      host = Katello::RegistrationManager.process_registration(rhsm_params, find_content_view_environments)

      host.reload

      update_host_registered_through(host, request.headers)

      render :json => Resources::Candlepin::Consumer.get(host.subscription_facet.uuid)
    end

    #api :DELETE, "/consumers/:id", N_("Unregister a consumer")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def consumer_destroy
      User.as_anonymous_admin do
        Katello::RegistrationManager.unregister_host(@host, :unregistering => !Setting['unregister_delete_host'])
      end
      render :plain => _("Deleted consumer '%s'") % params[:id], :status => :no_content
    end

    # used for registering with activation keys
    #api :POST, "/consumers", N_("Register a system with activation key (compatibility)")
    #param :activation_keys, String, :required => true
    def consumer_activate
      # Activation keys are userless by definition so use the internal generic user
      # Set it before calling find_activation_keys to allow communication with candlepin
      User.current = User.anonymous_admin
      additional_set_taxonomy
      activation_keys = find_activation_keys

      host = Katello::RegistrationManager.process_registration(rhsm_params, nil, activation_keys)

      update_host_registered_through(host, request.headers)
      host.reload

      render :json => Resources::Candlepin::Consumer.get(host.subscription_facet.uuid)
    end

    #api :GET, "/status", N_("Shows version information")
    #description N_("This service is available for unauthenticated users")
    def server_status
      candlepin_response = Resources::Candlepin::CandlepinPing.ping
      candlepin_response[:managerCapabilities] << 'combined_reporting'
      render :json => candlepin_response
    end

    #api :PUT, "/consumers/:id", N_("Update consumer information")
    def facts
      User.current = User.anonymous_admin
      @host.update_candlepin_associations(rhsm_params)
      update_host_registered_through(@host, request.headers)
      render :json => {:content => _("Facts successfully updated.")}, :status => :ok
    end

    def serials
      @host.subscription_facet.last_checkin = Time.now
      @host.subscription_facet.save!
      render :json => Katello::Resources::Candlepin::Consumer.serials(@host.subscription_facet.uuid)
    end

    def get_parent_host(headers)
      hostnames = headers["HTTP_X_FORWARDED_HOST"]
      host = hostnames.split(/[,,:]/)[0].strip if hostnames
      host || URI.parse(Setting[:foreman_url]).host
    end

    def get_content_source_id(hostname)
      proxies = SmartProxy.authorized.filter do |sp|
        hostname == URI.parse(sp.url).hostname
      end
      return nil if proxies.length != 1
      proxies.first.id
    end

    private

    # in case set taxonomy from core was skipped since the User.current was nil at that moment (typically AK was used instead of username/password)
    # we need to set proper context, unfortunately params[:organization_id] is already overridden again by set_organization_id so we need to
    # set correct parameter value and then reset it back
    def additional_set_taxonomy
      params[:organization_id], original = find_organization(:owner).id, params[:organization_id] if params[:owner].present?
      set_taxonomy
      params[:organization_id] = original if params[:owner].present?
    end

    def disable_strong_params
      params.permit!
    end

    def deny_access
      fail HttpErrors::Forbidden, 'Access denied'
    end

    def set_organization_id
      params[:organization_id] = params[:owner] if params[:owner]
    end

    def find_host(uuid = nil)
      uuid ||= params[:id]
      facet = Katello::Host::SubscriptionFacet.where(:uuid => uuid).first
      if facet.nil?
        # check with candlepin if consumer is Gone, raises RestClient::Gone
        User.as_anonymous_admin { Resources::Candlepin::Consumer.get(uuid) }
      end
      @host = ::Host::Managed.unscoped.find(facet.host_id)
    end

    def find_content_view_environments
      environments = []

      if params.key?(:environment_id)
        environments = [get_content_view_environment("cp_id", params[:environment_id])]
      elsif params.key?(:environments)
        if params['environments'].length > 1 && !Setting['allow_multiple_content_views']
          fail HttpErrors::BadRequest, _('Registering to multiple environments is not enabled.')
        end
        environments = params[:environments].map do |env|
          get_content_view_environment("cp_id", env['id'])
        end
      elsif params.key?(:organization_id) && !params.key?(:environment_id) && !params.key?(:environments)
        organization = Organization.current
        environments = organization.library.content_view_environment
      elsif User.current.default_organization.present?
        environments = User.current.default_organization.library.content_view_environment
      else
        fail HttpErrors::NotFound, _("User '%s' did not specify an organization ID and does not have a default organization.") % current_user.login
      end
      environments
    end

    def find_hypervisor_organization
      if User.consumer?
        host = find_host(User.current.uuid)
        @organization = host.organization
      elsif params[:owner]
        @organization = Organization.find_by(:label => params[:owner])
      end
      deny_access unless @organization
    end

    def find_organization(key = :organization_id)
      organization = nil

      if params.key?(key)
        label = params[key].is_a?(ActionController::Parameters) ? params[key]['key'] : params[key]
        organization = Organization.find_by(:label => label)
      end

      if organization.nil?
        message = _("Couldn't find Organization '%s'.")
        fail HttpErrors::NotFound, message % params[key]
      end

      if User.current && !User.consumer? && !User.current.allowed_organizations.include?(organization)
        message = _("User '%{user}' does not belong to Organization '%{organization}'.")
        fail HttpErrors::NotFound, message % {:user => current_user.login, :organization => params[key]}
      end

      organization
    end

    def convert_organization_label_to_id
      params[:organization_id] = find_organization.id
    end

    def convert_owner_to_organization_id
      params[:organization_id] = find_organization(:owner).id
    end

    def find_activation_keys
      organization = Organization.current

      if (ak_names = params[:activation_keys])
        fail HttpErrors::NotFound, _("Organization not found") if organization.nil?
        ak_names        = ak_names.split(",").uniq.compact
        activation_keys = ak_names.map do |ak_name|
          activation_key = organization.activation_keys.find_by(:name => ak_name)
          fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % ak_name unless activation_key

          if !activation_key.unlimited_hosts && activation_key.usage_count >= activation_key.max_hosts
            fail Errors::MaxHostsReachedException, _("Max Hosts (%{limit}) reached for activation key '%{name}'") %
                { :limit => activation_key.max_hosts, :name => activation_key.name }
          end
          activation_key
        end
      else
        activation_keys = []
      end
      if activation_keys.empty?
        fail HttpErrors::BadRequest, _("At least one activation key must be provided")
      end
      activation_keys
    end

    def get_content_view_environment(key, value)
      cve = nil
      if value
        cve = ContentViewEnvironment.where(key => value).first
        fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % value unless cve
        deny_access unless cve.readable? || User.consumer?
      end
      cve
    end

    def get_content_view_environments(label = nil, organization = nil)
      organization ||= @organization

      environments = ContentViewEnvironment.joins(:content_view => :organization).
          where("#{Organization.table_name}.id = ?", organization.id)
      environments = environments.where("#{Katello::ContentViewEnvironment.table_name}.label = ?", label) if label

      environments.reject do |env|
        (env.content_view.default && !env.environment.readable?) ||
            !env.content_view.readable? ||
            env.content_view.generated_for_repository?
      end
    end

    def rhsm_params
      params.slice(:name, :type, :facts, :installedProducts, :autoheal, :releaseVer, :usage, :role, :addOns, :serviceLevel, :uuid, :capabilities, :guestIds, :lastCheckin).to_h
    end

    def logger
      ::Foreman::Logging.logger('katello/cp_proxy')
    end

    def respond_for_index(options = {})
      collection = options[:collection] || resource_collection
      status     = options[:status] || :ok
      format     = options[:format] || :json

      render format => collection, :status => status
    end

    def respond_for_show(options = {})
      resource = options[:resource] || resource
      status   = options[:status] || :ok
      format   = options[:format] || :json

      render format => resource, :status => status
    end

    def authorize_client_or_user
      client_authorized? || authorize
    end

    def authorize_client_or_admin
      unless client_authorized?
        deny_access unless authorize
      end
    end

    def authorize_client
      deny_access unless client_authorized?
    end

    def client_authorized?
      authorized = authenticate_client && User.consumer?
      authorized = (User.current.uuid == @host.subscription_facet.uuid) if @host && User.consumer?
      authorized
    end

    def update_host_registered_through(host, headers)
      parent_host = get_parent_host(headers)
      host.subscription_facet.update_attribute(:registered_through, parent_host)
      content_source_id = get_content_source_id(parent_host)
      host.content_facet.update_attribute(:content_source_id, content_source_id)
    end

    def check_registration_services
      fail "Unable to register system, not all services available" unless Katello::RegistrationManager.check_registration_services
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def authorize_proxy_routes
      deny_access unless (authenticate || authenticate_client)

      route, params = Engine.routes.router.recognize(request) do |rte, parameters|
        break rte, parameters if rte.name
      end

      # route names are defined in routes.rb (:as => :name)
      case route.name
      when "rhsm_proxy_consumer_deletionrecord_delete_path"
        User.consumer? || Organization.deletable?
      when "rhsm_proxy_owner_pools_path"
        if params[:consumer]
          User.consumer? && current_user.uuid == params[:consumer]
        else
          User.consumer? || ::User.current.can?(:view_organizations, self)
        end
      when "rhsm_proxy_owner_servicelevels_path", "rhsm_proxy_owner_system_purpose_path"
        (User.consumer? || ::User.current.can?(:view_organizations, self))
      when "rhsm_proxy_consumer_accessible_content_path", "rhsm_proxy_consumer_certificates_path",
           "rhsm_proxy_consumer_releases_path", "rhsm_proxy_certificate_serials_path",
           "rhsm_proxy_consumer_entitlements_path", "rhsm_proxy_consumer_entitlements_post_path",
           "rhsm_proxy_consumer_entitlements_delete_path", "rhsm_proxy_consumer_entitlements_pool_delete_path",
           "rhsm_proxy_consumer_certificates_put_path", "rhsm_proxy_consumer_dryrun_path",
           "rhsm_proxy_consumer_owners_path", "rhsm_proxy_consumer_compliance_path", "rhsm_proxy_consumer_purpose_compliance_path"
        User.consumer? && current_user.uuid == params[:id]
      when "rhsm_proxy_consumer_certificates_delete_path"
        User.consumer? && current_user.uuid == params[:consumer_id]
      when "rhsm_proxy_pools_path"
        User.consumer? && current_user.uuid == params[:consumer]
      when "rhsm_proxy_subscriptions_post_path"
        User.consumer? && current_user.uuid == params[:consumer_uuid]
      when "rhsm_proxy_consumer_content_overrides_path", "rhsm_proxy_consumer_content_overrides_put_path",
           "rhsm_proxy_consumer_content_overrides_delete_path",
           "rhsm_proxy_consumer_guestids_path", "rhsm_proxy_consumer_guestids_get_guestid_path",
           "rhsm_proxy_consumer_guestids_put_path", "rhsm_proxy_consumer_guestids_put_guestid_path",
           "rhsm_proxy_consumer_guestids_delete_guestid_path",
           "rhsm_proxy_entitlements_path"
        # These queries are restricted in Candlepin
        User.consumer?
      when "rhsm_proxy_deleted_consumers_path"
        current_user.admin?
      when "rhsm_proxy_jobs_get_path"
        User.consumer? || current_user.admin?
      else
        Rails.logger.warn "Unknown proxy route #{request.method} #{request.fullpath}, access denied"
        deny_access
      end
    end
  end
end
