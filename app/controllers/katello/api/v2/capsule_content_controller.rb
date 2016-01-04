module Katello
  class Api::V2::CapsuleContentController < Api::V2::ApiController
    resource_description do
      api_base_url "/katello/api"
    end

    before_filter :find_capsule
    before_filter :find_environment, :only => [:add_lifecycle_environment, :remove_lifecycle_environment]

    def_param_group :lifecycle_environments do
      param :id, Integer, :desc => 'Id of the capsule', :required => true
      param :organization_id, Integer, :desc => 'Id of the organization to limit environments on'
    end

    def_param_group :update_lifecycle_environments do
      param :id, Integer, :desc => 'Id of the capsule', :required => true
      param :environment_id, Integer, :desc => 'Id of the lifecycle environment', :required => true
    end

    api :GET, '/capsules/:id/content/lifecycle_environments', 'List the lifecycle environments attached to the capsule'
    param_group :lifecycle_environments
    def lifecycle_environments
      environments = capsule_content.lifecycle_environments(params[:organization_id]).readable
      respond_for_lifecycle_environments_index(environments)
    end

    api :GET, '/capsules/:id/content/available_lifecycle_environments', 'List the lifecycle environments not attached to the capsule'
    param_group :lifecycle_environments
    def available_lifecycle_environments
      environments = capsule_content.available_lifecycle_environments(params[:organization_id]).readable
      respond_for_lifecycle_environments_index(environments)
    end

    api :POST, '/capsules/:id/content/lifecycle_environments', 'Add lifecycle environments to the capsule'
    param_group :update_lifecycle_environments
    def add_lifecycle_environment
      capsule_content.add_lifecycle_environment(@environment)
      respond_for_lifecycle_environments_index(capsule_content.lifecycle_environments)
    end

    api :DELETE, '/capsules/:id/content/lifecycle_environments/:environment_id',  'Remove lifecycle environments from the capsule'
    param_group :update_lifecycle_environments
    def remove_lifecycle_environment
      capsule_content.remove_lifecycle_environment(@environment)
      respond_for_lifecycle_environments_index(capsule_content.lifecycle_environments)
    end

    api :POST, '/capsules/:id/content/sync',  'Synchronize the content to the capsule'
    param :id, Integer, :desc => 'Id of the capsule', :required => true
    param :environment_id, Integer, :desc => 'Id of the environment to limit the synchronization on'
    def sync
      find_environment if params[:environment_id]
      task = async_task(::Actions::Katello::CapsuleContent::Sync, capsule_content, :environment => @environment)
      respond_for_async :resource => task
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

    def find_capsule
      @capsule = SmartProxy.authorized(:manage_capsule_content).find(params[:id])
      unless @capsule && @capsule.has_feature?(SmartProxy::PULP_NODE_FEATURE)
        fail _("This request may only be performed on a Capsule that has the Pulp Node feature.")
      end
    end

    def find_environment
      @environment = Katello::KTEnvironment.readable.find(params[:environment_id])
    end

    def capsule_content
      CapsuleContent.new(@capsule)
    end
  end
end
