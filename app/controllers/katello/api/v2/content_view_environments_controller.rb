module Katello
  class Api::V2::ContentViewEnvironmentsController < Api::V2::ApiController
    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_environment
    before_action :find_content_view
    before_action :find_activation_key
    before_action :find_host
    before_action :find_content_source

    resource_description do
      api_version "v2"
    end

    api :GET, "/content_view_environments", N_("List content view environments")
    param :organization_id, :number, :desc => N_("organization identifier"), :required => false
    param :lifecycle_environment_id, :number, :desc => N_("environment identifier"), :required => false
    param :content_view_id, :number, :desc => N_("Content view identifier"), :required => false
    param :activation_key_id, :number, :desc => N_("Activation key identifier"), :required => false
    param :host_id, :number, :desc => N_("Host identifier"), :required => false
    param :content_source_id, :number, :desc => N_("Content source identifier to filter by available lifecycle environments"), :required => false
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.distinct, :id, :asc, resource_class: ContentViewEnvironment))
    end

    def index_relation
      content_view_environments = ContentViewEnvironment.readable.non_generated
      content_view_environments = content_view_environments.in_organization(@organization) if @organization
      content_view_environments = content_view_environments.where(environment: @environment) if @environment
      content_view_environments = content_view_environments.where(content_view: @content_view) if @content_view
      content_view_environments = content_view_environments.where(id: @activation_key.content_view_environments) if @activation_key
      content_view_environments = content_view_environments.where(id: @host.content_view_environments) if @host

      # Filter by content source if provided (only show CVEnvs from environments on that capsule)
      if @content_source.present? && !@content_source.pulp_primary?
        available_env_ids = @content_source.lifecycle_environments.pluck(:id)
        content_view_environments = content_view_environments.where(environment_id: available_env_ids) if available_env_ids.any?
      end

      content_view_environments
    end

    def find_environment
      return unless params.key?(:lifecycle_environment_id)
      @environment = KTEnvironment.readable.find(params[:lifecycle_environment_id])
    end

    def find_content_view
      return unless params.key?(:content_view_id)
      @content_view = ContentView.readable.find(params[:content_view_id])
    end

    def find_activation_key
      return unless params.key?(:activation_key_id)
      @activation_key = ActivationKey.readable.find(params[:activation_key_id])
    end

    def find_host
      return unless params.key?(:host_id)
      @host = ::Host::Managed.authorized("view_hosts").find(params[:host_id])
    end

    def find_content_source
      return unless params.key?(:content_source_id)
      @content_source = SmartProxy.authorized(:view_smart_proxies).find(params[:content_source_id])
    end
  end
end
