module Katello
  class Api::V2::CapsuleContentController < Api::V2::ApiController
    resource_description do
      api_base_url "/katello/api"
    end

    before_action :find_capsule, :except => [:sync, :cancel_sync, :add_lifecycle_environment, :remove_lifecycle_environment]
    before_action :find_editable_capsule, :only => [:sync, :cancel_sync, :add_lifecycle_environment, :remove_lifecycle_environment]
    before_action :find_environment, :only => [:add_lifecycle_environment, :remove_lifecycle_environment]
    before_action :find_optional_organization, :only => [:sync_status]

    def_param_group :lifecycle_environments do
      param :id, Integer, :desc => N_('Id of the smart proxy'), :required => true
      param :organization_id, Integer, :desc => N_('Id of the organization to limit environments on')
    end

    def_param_group :update_lifecycle_environments do
      param :id, Integer, :desc => N_('Id of the smart proxy'), :required => true
      param :environment_id, Integer, :desc => N_('Id of the lifecycle environment'), :required => true
    end

    api :GET, '/capsules/:id/content/lifecycle_environments', N_('List the lifecycle environments attached to the smart proxy')
    param_group :lifecycle_environments
    def lifecycle_environments
      environments = @capsule.lifecycle_environments
      environment_org_scope = params[:organization_id] ? environments.where(organization_id: params[:organization_id]) : environments
      respond_for_lifecycle_environments_index(environment_org_scope)
    end

    api :GET, '/capsules/:id/content/available_lifecycle_environments', N_('List the lifecycle environments not attached to the smart proxy')
    param_group :lifecycle_environments
    def available_lifecycle_environments
      environments = @capsule.available_lifecycle_environments(params[:organization_id]).readable
      respond_for_lifecycle_environments_index(environments)
    end

    api :POST, '/capsules/:id/content/lifecycle_environments', N_('Add lifecycle environments to the smart proxy')
    param_group :update_lifecycle_environments
    def add_lifecycle_environment
      @capsule.add_lifecycle_environment(@environment)
      respond_for_lifecycle_environments_index(@capsule.lifecycle_environments)
    end

    api :DELETE, '/capsules/:id/content/lifecycle_environments/:environment_id', N_('Remove lifecycle environments from the smart proxy')
    param_group :update_lifecycle_environments
    def remove_lifecycle_environment
      @capsule.remove_lifecycle_environment(@environment)
      respond_for_lifecycle_environments_index(@capsule.lifecycle_environments)
    end

    api :POST, '/capsules/:id/content/sync', N_('Synchronize the content to the smart proxy')
    param :id, Integer, :desc => N_('Id of the smart proxy'), :required => true
    param :environment_id, Integer, :desc => N_('Id of the environment to limit the synchronization on')
    param :skip_metadata_check, :bool, :desc => N_('Skip metadata check on each repository on the smart proxy')
    def sync
      find_environment if params[:environment_id]
      skip_metadata_check = ::Foreman::Cast.to_bool(params[:skip_metadata_check])
      task = async_task(::Actions::Katello::CapsuleContent::Sync,
                        @capsule,
                        :environment_id => @environment.try(:id),
                        :skip_metadata_check => skip_metadata_check)
      respond_for_async :resource => task
    end

    api :GET, '/capsules/:id/content/sync', N_('Get current smart proxy synchronization status')
    param :id, Integer, :desc => N_('Id of the smart proxy'), :required => true
    param :organization_id, Integer, :desc => N_('Id of the organization to get the status for'), :required => false
    def sync_status
      @lifecycle_environments = @organization ? @capsule.lifecycle_environments.where(organization_id: @organization.id) : @capsule.lifecycle_environments
    end

    api :DELETE, '/capsules/:id/content/sync', N_('Cancel running smart proxy synchronization')
    param :id, Integer, :desc => N_('Id of the smart proxy'), :required => true
    def cancel_sync
      tasks = @capsule.cancel_sync
      if tasks.empty?
        render_message _('There\'s no running synchronization for this smart proxy.')
      else
        render_message _('Trying to cancel the synchronization...')
      end
    end

    protected

    def respond_for_lifecycle_environments_index(environments)
      collection = {
        :results => environments,
        :total => environments.size,
        :subtotal => environments.size
      }
      respond_for_index(:collection => collection, :template => :lifecycle_environments)
    end

    def find_editable_capsule
      @capsule = SmartProxy.unscoped.authorized(:manage_capsule_content).find(params[:id])
      unless @capsule&.has_feature?(SmartProxy::PULP_NODE_FEATURE)
        fail _("This request may only be performed on a Smart proxy that has the Pulp Node feature.")
      end
    end

    def find_capsule
      @capsule = SmartProxy.unscoped.authorized(:view_capsule_content).find(params[:id])
      unless @capsule&.has_feature?(SmartProxy::PULP_NODE_FEATURE)
        fail _("This request may only be performed on a Smart proxy that has the Pulp Node feature.")
      end
    end

    def find_environment
      @environment = Katello::KTEnvironment.readable.find(params[:environment_id])
    end

    def smart_proxy_service
      Pulp::SmartProxyRepository.new(@capsule)
    end
  end
end
