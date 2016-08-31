module Katello
  class Api::V2::OrganizationsController < ::Api::V2::OrganizationsController
    apipie_concern_subst(:a_resource => N_("an organization"), :resource => "organization")

    include Api::V2::Rendering
    include ForemanTasks::Triggers

    before_action :local_find_taxonomy, :only => %w(repo_discover cancel_repo_discover
                                                    download_debug_certificate
                                                    redhat_provider update
                                                    autoattach_subscriptions)

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
        param :media_ids, Array, N_("Media IDs"), :required => false
        param :config_template_ids, Array, N_("Provisioning template IDs"), :required => false # FIXME: deprecated
        param :ptable_ids, Array, N_("Partition template IDs"), :required => false
        param :provisioning_template_ids, Array, N_("Provisioning template IDs"), :required => false
        param :domain_ids, Array, N_("Domain IDs"), :required => false
        param :realm_ids, Array, N_("Realm IDs"), :required => false
        param :hostgroup_ids, Array, N_("Host group IDs"), :required => false
        param :environment_ids, Array, N_("Environment IDs"), :required => false
        param :subnet_ids, Array, N_("Subnet IDs"), :required => false
        param :label, String, :required => false
      end
    end

    def local_find_taxonomy
      find_taxonomy
    end

    api :GET, '/organizations', N_('List all organizations')
    param_group :search, Api::V2::ApiController
    def index
      @render_template = 'katello/api/v2/organizations/index'
      super
    end

    api :GET, '/organizations/:id', N_('Show organization')
    param :id, :identifier, :desc => N_("organization ID"), :required => true
    def show
      @render_template = 'katello/api/v2/organizations/show'
      super
    end

    api :PUT, '/organizations/:id', N_('Update organization')
    # The organization param hash below is redefined from foreman's ::Api::V2::TaxonomiesController
    # resource param_group instead of reusing the param_group :resource scoped from TaxonomiesController.
    # This is because name substitutions of the param group's name from :resource to :organization are limited
    # to the inclusion of a modules.
    param :id, :identifier, :desc => N_("organization ID"), :required => true
    param :redhat_repository_url, String, :desc => N_("Red Hat CDN URL")
    param_group :resource, ::Api::V2::TaxonomiesController
    def update
      if params.key?(:redhat_repository_url)
        sync_task(::Actions::Katello::Provider::Update, @organization.redhat_provider, params)
      end
      super
    end

    api :POST, '/organizations', N_('Create organization')
    param :name, String, :desc => N_("name"), :required => true
    param :label, String, :desc => N_("unique label")
    param :description, String, :desc => N_("description")
    param_group :resource
    def create
      @organization = Organization.new(resource_params)
      sync_task(::Actions::Katello::Organization::Create, @organization)
      @organization.reload
      respond_for_show :resource => @organization
    rescue
      process_resource_error
    end

    api :DELETE, '/organizations/:id', N_('Delete an organization')
    param :id, :number, :desc => N_("Organization ID"), :required => true
    def destroy
      task = async_task(::Actions::Katello::Organization::Destroy, @organization, nil)
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:id/repo_discover", N_("Discover Repositories")
    param :id, :number, :desc => N_("Organization ID"), :required => true
    param :url, String, :desc => N_("base url to perform repo discovery on")
    def repo_discover
      fail _("url not defined.") if params[:url].blank?
      task = async_task(::Actions::Katello::Repository::Discover, params[:url])
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

    api :POST, "/organizations/:id/autoattach_subscriptions", N_("Auto-attach available subscriptions to all hosts within an organization. Asynchronous operation."), :deprecated => true
    def autoattach_subscriptions
      task = async_task(::Actions::Katello::Organization::AutoAttachSubscriptions, @organization)
      respond_for_async :resource => task
    end

    api :GET, '/organizations/:id/redhat_provider', N_('List all :resource_id')
    def redhat_provider
      respond_for_show(:resource => @organization.redhat_provider,
                       :resource_name => "providers")
    end

    protected

    def action_permission
      if %w(download_debug_certificate redhat_provider repo_discover
            cancel_repo_discover autoattach_subscriptions).include?(params[:action])
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
