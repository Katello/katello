module Katello
  class Api::Rhsm::CandlepinProxiesController < Api::V2::ApiController
    include Katello::Authentication::ClientAuthentication

    before_action :disable_strong_params

    wrap_parameters false

    around_action :repackage_message
    before_action :find_host, :only => [:consumer_show, :consumer_destroy, :consumer_checkin, :enabled_repos,
                                        :upload_package_profile, :regenerate_identity_certificates, :facts,
                                        :available_releases, :serials, :upload_tracer_profile]
    before_action :authorize, :only => [:consumer_create, :list_owners, :rhsm_index]
    before_action :authorize_client_or_user, :only => [:consumer_show, :upload_package_profile, :regenerate_identity_certificates, :upload_tracer_profile, :facts, :proxy_jobs_get_path]
    before_action :authorize_client_or_admin, :only => [:hypervisors_update, :async_hypervisors_update]
    before_action :authorize_proxy_routes, :only => [:get, :post, :put, :delete]
    before_action :authorize_client, :only => [:consumer_destroy, :consumer_checkin,
                                               :enabled_repos, :available_releases]

    before_action :add_candlepin_version_header

    before_action :proxy_request_path, :proxy_request_body
    before_action :set_organization_id, :except => [:hypervisors_update, :async_hypervisors_update]
    before_action :find_hypervisor_organization, :only => [:async_hypervisors_update, :hypervisors_update]

    before_action :check_content_type, :except => :async_hypervisors_update

    skip_before_action :set_taxonomy, :only => [:rhsm_index, :consumer_activate, :consumer_create]

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

        # rubocop:disable HandleExceptions
        rescue JSON::ParserError
          # Not a json response, leave as-is
        end
      end
    end

    rescue_from RestClient::Exception do |e|
      Rails.logger.error pp_exception(e)
      if request_from_katello_cli?
        render :json => { :errors => [e.http_body] }, :status => e.http_code
      else
        render :text => e.http_body, :status => e.http_code
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
      r = Resources::Candlepin::Proxy.get(@request_path)
      logger.debug r
      render :json => r
    end

    def delete
      r = Resources::Candlepin::Proxy.delete(@request_path, @request_body.read)
      logger.debug r
      render :json => r
    end

    def post
      r = Resources::Candlepin::Proxy.post(@request_path, @request_body.read)
      logger.debug r
      render :json => r
    end

    def put
      r = Resources::Candlepin::Proxy.put(@request_path, @request_body.read)
      logger.debug r
      render :json => r
    end

    #api :GET, "/consumers/:id", N_("Show a system")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def consumer_show
      render :json => Resources::Candlepin::Consumer.get(params[:id])
    end

    #api :GET, "/owners/:organization_id/environments", N_("List environments for RHSM")
    def rhsm_index
      organization = find_organization
      @all_environments = get_content_view_environments(params[:name], organization).collect do |env|
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
      task = Katello::Resources::Candlepin::Consumer.async_hypervisors(params[:owner], request.raw_post)
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
        sync_task(::Actions::Katello::Host::Hypervisors, params.except(:controller, :action, :format))
      end
      render :json => task.output[:results]
    end

    #api :PUT, "/consumers/:id/checkin/", N_("Update consumer check-in time")
    #param :date, String, :desc => N_("check-in time")
    def consumer_checkin
      @host.update_attributes(:last_checkin => params[:date])
      Candlepin::Consumer.new(@host.subscription_facet.uuid, @host.organization.label).checkin(params[:date])
      render :json => Resources::Candlepin::Consumer.get(@host.subscription_facet.uuid)
    end

    api :PUT, "/consumers/:id/tracer", N_("Update services requiring restart")
    param :traces, Hash, :required => true
    def upload_tracer_profile
      User.as_anonymous_admin do
        @host.import_tracer_profile(params[:traces])
      end
      render :json => Resources::Candlepin::Consumer.get(@host.subscription_facet.uuid)
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
      Used by katello-agent to keep the information about enabled repositories up to date.
      This information is then used for computing the errata available for the system.
    DESC
    param :enabled_repos, Hash, :required => true do
      param :repos, Array, :required => true do
        param :baseurl, Array, :desc => N_("List of enabled repo urls for the repo (Only first is used.)"), :required => false
      end
    end
    param :id, String, :desc => N_("UUID of the system"), :required => true
    def enabled_repos
      repos_params = params['enabled_repos'] rescue raise(HttpErrors::BadRequest, _("Expected attribute is missing:") + " enabled_repos")
      repos_params = repos_params['repos'] || []

      paths = repos_params.map do |repo|
        if !repo['baseurl'].blank?
          URI(repo['baseurl'].first).path
        else
          logger.warn("System #{@host.name} (#{@host.id}) attempted to bind to unspecific repo (#{repo}).")
          nil
        end
      end

      result = nil
      User.as_anonymous_admin do
        result = @host.content_facet.update_repositories_by_paths(paths.compact)
      end

      respond_for_show :resource => result
    end

    #api :POST, "/environments/:environment_id/consumers", N_("Register a consumer in environment")
    def consumer_create
      content_view_environment = find_content_view_environment
      host = Katello::Host::SubscriptionFacet.find_or_create_host(content_view_environment.environment.organization, rhsm_params)

      sync_task(::Actions::Katello::Host::Register, host, rhsm_params, content_view_environment)
      host.reload

      update_host_registered_through(host, request.headers)

      render :json => Resources::Candlepin::Consumer.get(host.subscription_facet.uuid)
    end

    #api :DELETE, "/consumers/:id", N_("Unregister a consumer")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def consumer_destroy
      User.as_anonymous_admin do
        if Setting['unregister_delete_host']
          sync_task(::Actions::Katello::Host::Destroy, @host)
        else
          sync_task(::Actions::Katello::Host::Unregister, @host)
        end
      end
      render :text => _("Deleted consumer '%s'") % params[:id], :status => 204
    end

    # used for registering with activation keys
    #api :POST, "/consumers", N_("Register a system with activation key (compatibility)")
    #param :activation_keys, String, :required => true
    def consumer_activate
      # Activation keys are userless by definition so use the internal generic user
      # Set it before calling find_activation_keys to allow communication with candlepin
      User.current = User.anonymous_admin
      activation_keys = find_activation_keys
      host = Katello::Host::SubscriptionFacet.find_or_create_host(activation_keys.first.organization, rhsm_params)

      sync_task(::Actions::Katello::Host::Register, host, rhsm_params, nil, activation_keys)

      update_host_registered_through(host, request.headers)
      host.reload

      render :json => Resources::Candlepin::Consumer.get(host.subscription_facet.uuid)
    end

    #api :GET, "/status", N_("Shows version information")
    #description N_("This service is available for unauthenticated users")
    def server_status
      candlepin_response = Resources::Candlepin::CandlepinPing.ping
      status = { :managerCapabilities => candlepin_response['managerCapabilities'],
                 :result => candlepin_response['result'],
                 :rulesSource => candlepin_response['rulesSource'],
                 :rulesVersion => candlepin_response['rulesVersion'],
                 :standalone => candlepin_response['standalone'],
                 :timeUTC => Time.now.getutc,
                 :version => Katello::VERSION }

      render :json => status
    end

    #api :PUT, "/consumers/:id", N_("Update consumer information")
    def facts
      User.current = User.anonymous_admin
      async_task(::Actions::Katello::Host::Update, @host, rhsm_params)
      update_host_registered_through(@host, request.headers)
      render :json => {:content => _("Facts successfully updated.")}, :status => 200
    end

    def serials
      @host.subscription_facet.last_checkin = DateTime.now
      @host.subscription_facet.save!
      render :json => Katello::Resources::Candlepin::Consumer.serials(@host.subscription_facet.uuid)
    end

    def get_parent_host(headers)
      hostnames = headers["HTTP_X_FORWARDED_SERVER"]
      host = hostnames.split(",")[0] if hostnames
      host || Facter.value(:fqdn) || SETTINGS[:fqdn]
    end

    private

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
        fail HttpErrors::NotFound, _("Couldn't find consumer '%s'") % uuid
      end
      @host = ::Host::Managed.unscoped.find(facet.host_id)
    end

    def find_content_view_environment
      environment = nil

      if params.key?(:environment_id)
        environment = get_content_view_environment("cp_id", params[:environment_id])
      elsif params.key?(:organization_id) && !params.key?(:environment_id)
        organization = find_organization
        environment = organization.library.content_view_environment
      elsif User.current.default_organization.present?
        environment = User.current.default_organization.library.content_view_environment
      else
        fail HttpErrors::NotFound, _("User '%s' did not specify an organization ID and does not have a default organization.") % current_user.login
      end

      environment
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

    def find_organization
      organization = nil

      if params.key?(:organization_id)
        organization = Organization.find_by(:label => params[:organization_id])
      end

      if organization.nil?
        message = _("Couldn't find Organization '%s'.")
        fail HttpErrors::NotFound, message % params[:organization_id]
      end

      if User.current && !User.consumer? && !User.current.allowed_organizations.include?(organization)
        message = _("User '%{user}' does not belong to Organization '%{organization}'.")
        fail HttpErrors::NotFound, message % {:user => current_user.login, :organization => params[:organization_id]}
      end

      organization
    end

    def find_activation_keys
      organization = find_organization

      if (ak_names = params[:activation_keys])
        ak_names        = ak_names.split(",")
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

      environments.reject { |env| (env.content_view.default && !env.environment.readable?) || !env.content_view.readable? }
    end

    def rhsm_params
      params.slice(:name, :type, :facts, :installedProducts, :autoheal, :releaseVer, :serviceLevel, :uuid, :capabilities, :guestIds, :lastCheckin)
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
    end

    # rubocop:disable MethodLength
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
        find_organization
        if params[:consumer]
          User.consumer? && current_user.uuid == params[:consumer]
        else
          User.consumer? || ::User.current.can?(:view_organizations, self)
        end
      when "rhsm_proxy_owner_servicelevels_path"
        find_organization
        (User.consumer? || ::User.current.can?(:view_organizations, self))
      when "rhsm_proxy_consumer_certificates_path", "rhsm_proxy_consumer_releases_path", "rhsm_proxy_certificate_serials_path",
           "rhsm_proxy_consumer_entitlements_path", "rhsm_proxy_consumer_entitlements_post_path",
           "rhsm_proxy_consumer_entitlements_delete_path", "rhsm_proxy_consumer_certificates_put_path",
           "rhsm_proxy_consumer_dryrun_path", "rhsm_proxy_consumer_owners_path",
           "rhsm_proxy_consumer_compliance_path"
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
