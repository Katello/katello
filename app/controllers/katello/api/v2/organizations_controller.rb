module Katello
  class Api::V2::OrganizationsController < ::Api::V2::OrganizationsController
    apipie_concern_subst(:a_resource => N_("an organization"), :resource => "organization")

    include Api::V2::Rendering
    include ForemanTasks::Triggers

    before_action :local_find_taxonomy, :only => %w(repo_discover cancel_repo_discover
                                                    download_debug_certificate cdn_configuration
                                                    redhat_provider update releases)

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def_param_group :resource do
      param :organization, Hash, :required => true, :action_aware => true do
        param :name, String, :required => true
        param :description, String, :required => false
        param :user_ids, Array, N_("User IDs"), :required => false
        param :smart_proxy_ids, Array, N_("Smart proxy IDs"), :required => false
        param :compute_resource_ids, Array, N_("Compute resource IDs"), :required => false
        param :medium_ids, Array, N_("Medium IDs"), :required => false
        param :ptable_ids, Array, N_("Partition template IDs"), :required => false
        param :provisioning_template_ids, Array, N_("Provisioning template IDs"), :required => false
        param :domain_ids, Array, N_("Domain IDs"), :required => false
        param :realm_ids, Array, N_("Realm IDs"), :required => false
        param :hostgroup_ids, Array, N_("Host group IDs"), :required => false
        param :environment_ids, Array, N_("Environment IDs"), :required => false
        param :subnet_ids, Array, N_("Subnet IDs"), :required => false
        param :ignore_types, Array, N_("List of resources types that will be automatically associated"), :required => false
        param :location_ids, Array, N_("Associated location IDs"), :required => false
      end
    end

    def local_find_taxonomy
      find_taxonomy
    end

    api :GET, '/organizations', N_('List all organizations')
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Organization)
    def index
      @render_template = 'katello/api/v2/organizations/index'
      super
    end

    api :GET, '/organizations/:id', N_('Show organization')
    param :id, :number, :desc => N_("organization ID"), :required => true
    def show
      @render_template = 'katello/api/v2/organizations/show'
      super
    end

    api :PUT, '/organizations/:id', N_('Update organization')
    param :id, :number, :desc => N_("organization ID"), :required => true
    param :redhat_repository_url, String, :desc => N_("Red Hat CDN URL"), deprecated: true
    param_group :resource
    def update
      if params[:redhat_repository_url]
        sync_task(::Actions::Katello::CdnConfiguration::Update, @organization.cdn_configuration, url: params[:redhat_repository_url], type: CdnConfiguration::CUSTOM_CDN_TYPE)
      end
      super
    end

    api :POST, '/organizations', N_('Create organization')
    param_group :resource
    param :organization, Hash do
      param :label, String, :required => false
    end
    def create
      @organization = Organization.new(resource_params)
      creator = ::Katello::OrganizationCreator.new(@organization)
      creator.create!
      @organization.reload
      # @taxonomy instance variable is necessary for foreman side
      # app/views/api/v2/taxonomies/show.json.rabl is using it.
      @taxonomy = @organization
      respond_for_create :resource => @organization
    rescue => e
      ::Foreman::Logging.exception('Could not create organization', e)
      # Force @organization.errors to be populated
      # Organization.new may raise so @organization may not be set
      @organization&.valid?
      process_resource_error(message: e.message, resource: @organization)
    end

    api :DELETE, '/organizations/:id', N_('Delete an organization')
    param :id, :number, :desc => N_("Organization ID"), :required => true
    def destroy
      task = async_task(::Actions::Katello::Organization::Destroy, @organization, nil)
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:id/repo_discover", N_("Discover Repositories")
    param :id, :number, :desc => N_("Organization ID"), :required => true
    param :url, String, :desc => N_("Base URL to perform repo discovery on")
    param :content_type, String, :desc => N_("One of yum or docker")
    param :upstream_username, String, :desc => N_("Username to access URL")
    param :upstream_password, String, :desc => N_("Password to access URL")
    param :search, String, :desc => N_("Search pattern (defaults to '*')")
    def repo_discover
      fail _("url not defined.") if params[:url].blank?
      registry_search = params[:search].empty? ? '*' : params[:search]
      task = async_task(::Actions::Katello::Repository::Discover, params[:url], params[:content_type],
                        params[:upstream_username], params[:upstream_password], registry_search)
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:label/cancel_repo_discover", N_("Cancel repository discovery")
    param :label, String, :desc => N_("Organization label")
    param :url, String, :desc => N_("base url to perform repo discovery on")
    def cancel_repo_discover
      task = @organization.cancel_repo_discovery
      respond_for_async :resource => task
    end

    api :GET, "/organizations/:label/download_debug_certificate", N_("Download a debug certificate")
    param :label, String, :desc => N_("Organization label")
    def download_debug_certificate
      pem = @organization.debug_cert
      data = "#{pem[:key]}\n\n#{pem[:cert]}"
      send_data data,
                :filename => "#{@organization.name}-key-cert.pem",
                :type => "application/text"
    end

    api :GET, "/organizations/:id/releases", N_("List available releases in the organization")
    param :id, String, :desc => N_("ID of the Organization"), :required => true
    def releases
      available_releases = @organization.library.available_releases
      response = {
        :results => available_releases,
        :total => available_releases.size,
        :subtotal => available_releases.size,
      }
      respond_for_index :collection => response
    end

    api :PUT, "/organizations/:id/cdn_configuration", N_("Update the CDN configuration")
    param :id, String, :desc => N_("ID of the Organization"), :required => true
    param :type, String, :desc => N_("CDN configuration type. One of %s.") % CdnConfiguration::TYPES.join(", "), :required => true
    param :url, String, :desc => N_("Upstream foreman server to sync CDN content from. Relevant only for 'upstream_server' type.")
    param :username, String, :desc => N_("Username for authentication. Relevant only for 'upstream_server' type.")
    param :password, String, :desc => N_("Password for authentication. Relevant only for 'upstream_server' type.")
    param :upstream_organization_label, String, :desc => N_("Upstream organization to sync CDN content from. Relevant only for 'upstream_server' type.")
    param :upstream_content_view_label, String, :desc => N_("Upstream Content View Label, default: Default_Organization_View. Relevant only for 'upstream_server' type.")
    param :upstream_lifecycle_environment_label, String, :desc => N_("Upstream Lifecycle Environment, default: Library. Relevant only for 'upstream_server' type.")
    param :ssl_ca_credential_id, Integer, :desc => N_("Content Credential to use for SSL CA. Relevant only for 'upstream_server' type.")
    param :custom_cdn_auth_enabled, :bool, :desc => N_("If product certificates should be used to authenticate to a custom CDN.")
    def cdn_configuration
      config_keys = [:url, :username, :password, :upstream_organization_label, :ssl_ca_credential_id, :type,
                     :upstream_lifecycle_environment_label, :upstream_content_view_label, :custom_cdn_auth_enabled]
      config_params = params.slice(*config_keys).permit!.to_h

      task = sync_task(::Actions::Katello::CdnConfiguration::Update, @organization.cdn_configuration, config_params)

      respond_for_async :resource => task
    end

    api :GET, '/organizations/:id/redhat_provider', N_('List all :resource_id'), deprecated: true
    def redhat_provider
      respond_for_show(:resource => @organization.redhat_provider,
                       :resource_name => "providers")
    end

    protected

    def action_permission
      if params[:action] == "releases"
        :view
      elsif params[:action] == "download_debug_certificate" &&
          Organization.find(params[:id]).authorized?(:export_content)
        :view
      elsif %w(download_debug_certificate redhat_provider repo_discover cdn_configuration
               cancel_repo_discover).include?(params[:action])
        :edit
      else
        super
      end
    end

    def resource_identifying_attributes
      %w(id label)
    end

    def skip_nested_id
      ["default_content_view_id", "library_id"]
    end
  end
end
