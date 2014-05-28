#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class Api::V1::CandlepinProxiesController < Api::V1::ApiController

    include Katello::Authentication::ClientAuthentication

    before_filter :find_system, :only => [:consumer_show, :consumer_destroy, :consumer_checkin, :enabled_repos,
                                          :upload_package_profile, :regenerate_identity_certificates, :facts]
    before_filter :authorize, :only => [:consumer_create, :list_owners, :rhsm_index]
    before_filter :authorize_client_or_user, :only => [:upload_package_profile, :regenerate_identity_certificates,
                                                       :hypervisors_update]
    before_filter :authorize_proxy_routes, :only => [:get, :post, :put, :delete]
    before_filter :authorize_client, :only => [:consumer_show, :consumer_destroy, :consumer_checkin,
                                               :enabled_repos, :facts]

    before_filter :add_candlepin_version_header

    before_filter :proxy_request_path, :proxy_request_body
    before_filter :set_organization_id
    before_filter :find_organization, :only => [:rhsm_index, :consumer_activate]
    before_filter :find_default_organization_and_or_environment, :only => [:consumer_create, :consumer_activate]
    before_filter :find_optional_organization, :only => [:consumer_create, :hypervisors_update, :consumer_activate]
    before_filter :find_only_environment, :only => [:consumer_create]
    before_filter :find_environment_and_content_view, :only => [:consumer_create]
    before_filter :find_content_view, :only => [:consumer_create, :facts]
    before_filter :find_hypervisor_environment_and_content_view, :only => [:hypervisors_update]

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
      prefix = "#{Katello.config.url_prefix}/api"
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
      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
    end

    #api :GET, "/owners/:organization_id/environments", N_("List environments for RHSM")
    def rhsm_index
      @all_environments = get_content_view_environments(query_params[:name]).collect do |env|
        {
          :id  => env.cp_id,
          :name => env.label,
          :display_name => env.name,
          :description => env.content_view.description
        }
      end

      respond_for_index :collection => @all_environments
    end

    #api :POST, "/hypervisors", N_("Update the hypervisors information for environment")
    #desc 'See virt-who tool for more details.'
    def hypervisors_update
      cp_response, _ = System.register_hypervisors(@environment, @content_view, params.except(:controller, :action, :format))
      render :json => cp_response
    end

    #api :PUT, "/consumers/:id/checkin/", N_("Update consumer check-in time")
    #param :date, String, :desc => N_("check-in time")
    def consumer_checkin
      @system.checkin(params[:date])
      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
    end

    #api :PUT, "/consumers/:id/packages", N_("Update installed packages")
    #api :PUT, "/consumers/:id/profile", N_("Update installed packages")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def upload_package_profile
      fail HttpErrors::BadRequest, _("No package profile received for %s") % @system.name unless params.key?(:_json)
      @system.upload_package_profile(params[:_json])
      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
    end

    def list_owners
      orgs = User.current.allowed_organizations
      # rhsm expects owner (Candlepin format)
      # rubocop:disable SymbolName
      respond_for_index :collection => orgs.map { |o| { :key => o.label, :displayName => o.name } }
    end

    #api :POST, "/consumers/:id", N_("Regenerate consumer identity")
    #param :id, String, :desc => N_("UUID of the consumer")
    #desc 'Schedules the consumer identity certificate regeneration'
    def regenerate_identity_certificates
      @system.regenerate_identity_certificates
      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
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
    # rubocop:disable MethodLength
    def enabled_repos
      repos_params = params['enabled_repos'] rescue raise(HttpErrors::BadRequest, _("Expected attribute is missing:") + " enabled_repos")
      repos_params = repos_params['repos'] || []

      unknown_paths = []
      repos = []
      repos_params.each do |repo|
        if !repo['baseurl'].blank?
          path = URI(repo['baseurl'].first).path
          possible_repos = Repository.where(:relative_path => path.gsub('/pulp/repos/', ''))
          if possible_repos.empty?
            unknown_paths << path
            logger.warn("System #{@system.name} (#{@system.id}) requested binding to unknown repo #{path}")
          else
            repos << possible_repos.first
            logger.warn("System #{@system.name} (#{@system.id}) requested binding to path #{path} matching" +
                         "#{possible_repos.size} repositories.") if possible_repos.size > 1
          end
        else
          logger.warn("System #{@system.name} (#{@system.id}) attempted to bind to unspecific repo (#{repo}).")
        end
      end

      pulp_ids = repos.collect{|r| r.pulp_id}
      processed_ids, error_ids = @system.enable_yum_repos(pulp_ids)

      result                  = {}
      result[:processed_ids]  = processed_ids
      result[:error_ids]      = error_ids
      result[:unknown_labels] = unknown_paths
      if error_ids.present? || unknown_paths.present?
        result[:result] = "error"
      else
        result[:result] = "ok"
      end

      respond_for_show :resource => result
    end

    #api :POST, "/environments/:environment_id/consumers", N_("Register a consumer in environment")
    def consumer_create
      foreman_host = find_foreman_host

      @system = System.new(system_params.merge(:environment  => @environment,
                                               :content_view => @content_view,
                                               :serviceLevel => params[:service_level],
                                               :host_id      => foreman_host.try(:id)))

      sync_task(::Actions::Katello::System::Create, @system)
      @system.reload
      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
    end

    #api :DELETE, "/consumers/:id", N_("Unregister a consumer")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def consumer_destroy
      @system.destroy
      render :text => _("Deleted consumer '%s'") % params[:id], :status => 204
    end

    # used for registering with activation keys
    #api :POST, "/consumers", N_("Register a system with activation key (compatibility)")
    #param :activation_keys, String, :required => true
    def consumer_activate
      # Activation keys are userless by definition so use the internal generic user
      # Set it before calling find_activation_keys to allow communication with candlepin
      User.current    = User.hidden.first
      activation_keys = find_activation_keys
      foreman_host    = find_foreman_host

      @system = System.new(system_params.merge(:host_id => foreman_host.try(:id)))
      sync_task(::Actions::Katello::System::Create, @system, activation_keys)
      @system.reload

      render :json => Resources::Candlepin::Consumer.get(@system.uuid)
    end

    def facts
      attrs = params.clone
      slice_attrs = [:name, :description, :location,
                     :facts, :guestIds, :installedProducts,
                     :releaseVer, :serviceLevel, :lastCheckin
                     ]
      attrs[:installedProducts] = [] if attrs.key?(:installedProducts) && attrs[:installedProducts].nil?

      @system.update_attributes!(attrs.slice(*slice_attrs))

      render :json => {:content => _("Facts successfully updated.")}, :status => 200
    end

    private

    def get_organization(org_id)
      return Organization.without_deleting.having_name_or_label(org_id).first
    end

    def set_organization_id
      params[:organization_id] = params[:owner] if params[:owner]
    end

    def find_system
      @system = System.first(:conditions => { :uuid => params[:id] })
      if @system.nil?
        # check with candlepin if consumer is Gone, raises RestClient::Gone
        Resources::Candlepin::Consumer.get params[:id]
        fail HttpErrors::NotFound, _("Couldn't find consumer '%s'") % params[:id]
      end
      @system
    end

    def find_default_organization_and_or_environment
      # This has to grab the first default org associated with this user AND
      # the environment that goes with him.
      return if params.key?(:organization_id) || params.key?(:owner) || params.key?(:environment_id)

      #At this point we know that they didn't supply an org or environment, so we can look up the default
      @environment = current_user.default_environment
      if @environment
        @organization = @environment.organization
      else
        fail HttpErrors::NotFound, _("You have not set a default organization and environment on the user %s.") % current_user.login
      end
    end

    def find_only_environment
      if !@environment && @organization && !params.key?(:environment_id)
        if @organization.kt_environments.empty?
          fail HttpErrors::BadRequest, _("Organization %{org} has the '%{env}' environment only. Please create an environment for system registration.") %
            { :org => @organization.name, :env => "Library" }
        end

        # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
        # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
        # this scenario, if the org passed in matches the user's default org, use the default env. If not use
        # the single env of the org or throw an error if more than one.
        #
        if @organization.kt_environments.size > 1
          if current_user.default_environment && current_user.default_environment.organization == @organization
            @environment = current_user.default_environment
          else
            fail HttpErrors::BadRequest, _("Organization %s has more than one environment. Please specify target environment for system registration.") % @organization.name
          end
        else
          if @environment = @organization.kt_environments.first
            return
          end
        end
      end
    end

    def find_content_view
      if (content_view_id = (params[:content_view_id] || params[:system].try(:[], :content_view_id)))
        setup_content_view(content_view_id)
      end
    end

    def find_environment_and_content_view
      # There are some scenarios (primarily create) where a system may be
      # created using the content_view_environment.cp_id which is the
      # equivalent of "environment_id"-"content_view_id".
      return unless params.key?(:environment_id)

      if params[:environment_id].is_a? String
        if !params.key?(:content_view_id)
          cve = get_content_view_environment_by_cp_id(params[:environment_id])
          @environment = cve.environment
          @organization = @environment.organization
          @content_view = cve.content_view
        else
          # assumption here is :content_view_id is passed as a separate attrib
          @environment = KTEnvironment.find(params[:environment_id])
          @organization = @environment.organization
          fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
        end
        return @environment, @content_view
      else
        find_environment
      end
    end

    def find_hypervisor_environment_and_content_view
      cve = get_content_view_environment_by_label(params[:env])
      @environment = cve.environment
      @content_view = cve.content_view
    end

    def find_activation_keys
      if ak_names = params[:activation_keys]
        ak_names        = ak_names.split(",")
        activation_keys = ak_names.map do |ak_name|
          activation_key = @organization.activation_keys.find_by_name(ak_name)
          fail HttpErrors::NotFound, _("Couldn't find activation key '%s'") % ak_name unless activation_key
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

    def find_foreman_host
      if params[:facts].present? && params[:facts]['network.hostname'].present?
        foreman_host = Host.where(:name => params[:facts]['network.hostname'], :organization_id => @organization).first
      end
      foreman_host
    end

    def get_content_view_environment_by_label(label)
      get_content_view_environment("label", label)
    end

    def get_content_view_environment(key, value)
      cve = nil
      if value
        cve = ContentViewEnvironment.where(key => value).first
        fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % value unless cve
      end
      cve
    end

    def get_content_view_environment_by_cp_id(id)
      get_content_view_environment("cp_id", id)
    end

    def get_content_view_environments(label = nil)
      environments = ContentViewEnvironment.joins(:content_view => :organization).
          where("#{Organization.table_name}.id = ?", @organization.id)
      environments = environments.where("#{Katello::ContentViewEnvironment.table_name}.label = ?", label) if label

      environments.delete_if do |env|
        if env.content_view.default
          !env.environment.readable?
        else
          !env.content_view.readable?
        end
      end

      environments
    end

    def system_params
      system_params = params.slice(:name, :organization_id, :facts, :installedProducts)

      if params.key?(:cp_type)
        system_params[:cp_type] = params[:cp_type]
      elsif params.key?(:type)
        system_params[:cp_type] = params[:type]
      end

      system_params
    end

    def logger
      ::Logging.logger['cp_proxy']
    end

    def add_candlepin_version_header
      response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello.config.katello_version}"
    end

    def authorize_client_or_user
      client_authorized? || authorize
    end

    def authorize_client
      deny_access if !client_authorized?
    end

    def client_authorized?
      authorized = authenticate_client && User.consumer?
      authorized = (User.current.uuid == @system.uuid) if @system && User.consumer?
      authorized
    end

    # rubocop:disable MethodLength
    def authorize_proxy_routes
      deny_access if !(authenticate || authenticate_client)

      route, _, params = Engine.routes.router.recognize(request) do |rte, match, parameters|
        break rte, match, parameters if rte.name
      end

      # route names are defined in routes.rb (:as => :name)
      case route.name
      when "api_proxy_consumer_deletionrecord_delete_path"
        User.consumer? || Organization.deletable?
      when "api_proxy_owner_pools_path"
        find_optional_organization
        if params[:consumer]
          User.consumer? && current_user.uuid == params[:consumer]
        else
          User.consumer? || ::User.current.can?(:view_organizations, self)
        end
      when "api_proxy_owner_servicelevels_path"
        find_optional_organization
        (User.consumer? || ::User.current.can?(:view_organizations, self))
      when "api_proxy_consumer_certificates_path", "api_proxy_consumer_releases_path", "api_proxy_certificate_serials_path",
           "api_proxy_consumer_entitlements_path", "api_proxy_consumer_entitlements_post_path",
           "api_proxy_consumer_entitlements_delete_path",
           "api_proxy_consumer_dryrun_path", "api_proxy_consumer_owners_path",
           "api_proxy_consumer_compliance_path"
        User.consumer? && current_user.uuid == params[:id]
      when "api_proxy_consumer_certificates_delete_path"
        User.consumer? && current_user.uuid == params[:consumer_id]
      when "api_proxy_pools_path"
        User.consumer? && current_user.uuid == params[:consumer]
      when "api_proxy_subscriptions_post_path"
        User.consumer? && current_user.uuid == params[:consumer_uuid]
      when "api_proxy_consumer_content_overrides_path", "api_proxy_consumer_content_overrides_put_path",
           "api_proxy_consumer_content_overrides_delete_path",
           "api_proxy_consumer_guestids_path", "api_proxy_consumer_guestids_get_guestid_path",
           "api_proxy_consumer_guestids_put_path", "api_proxy_consumer_guestids_put_guestid_path",
           "api_proxy_consumer_guestids_delete_guestid_path",
           "api_proxy_entitlements_path"
        # These queries are restricted in Candlepin
        User.consumer?
      when "api_proxy_deleted_consumers_path"
        current_user.admin?
      else
        Rails.logger.warn "Unknown proxy route #{request.method} #{request.fullpath}, access denied"
        deny_access
      end
    end

  end
end
