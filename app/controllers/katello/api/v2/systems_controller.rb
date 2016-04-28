module Katello
  class Api::V2::SystemsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    respond_to :json

    wrap_parameters :include => (System.attribute_names + %w(type autoheal facts guest_ids host_collection_ids installed_products content_view environment service_level release_ver last_checkin))

    skip_before_filter :set_default_response_format, :only => :report

    before_filter :find_system, :only => [:show, :update, :enabled_repos, :releases, :tasks,
                                          :content_override, :product_content]
    before_filter :find_environment, :only => [:index, :report]
    before_filter :find_optional_organization, :only => [:create, :index, :report]
    before_filter :find_host_collection, :only => [:index]
    before_filter :find_default_organization_and_or_environment, :only => [:create, :index]

    before_filter :find_environment_and_content_view, :only => [:create]
    before_filter :find_content_view, :only => [:create, :update]
    before_filter :authorize_environment, :only => [:create]

    def organization_id_keys
      [:organization_id, :owner]
    end

    def_param_group :system do
      param :facts, Hash, :desc => N_("Key-value hash of content host-specific facts"), :action_aware => true do
        param :fact, String, :desc => N_("Any number of facts about this content host")
      end
      param :installed_products, Array, :desc => N_("List of products installed on the content host"), :action_aware => true
      param :name, String, :desc => N_("Name of the content host"), :required => true, :action_aware => true
      param :type, String, :desc => N_("Type of the content host, it should always be 'content host'"), :required => true, :action_aware => true
      param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
      param :location, String, :desc => N_("Physical location of the content host")
      param :content_view_id, :identifier
      param :environment_id, :identifier
    end

    api :GET, "/systems", N_("List content hosts"), :deprecated => true
    api :POST, "/systems/post_index", N_("List content hosts when you have a query string parameter that will cause a 414."), :deprecated => true
    api :GET, "/organizations/:organization_id/systems", N_("List content hosts in an organization"), :deprecated => true
    api :GET, "/environments/:environment_id/systems", N_("List content hosts in environment"), :deprecated => true
    param :name, String, :desc => N_("Filter content host by name")
    param :pool_id, String, :desc => N_("Filter content host by subscribed pool")
    param :uuid, String, :desc => N_("Filter content host by uuid")
    param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
    param :environment_id, String, :desc => N_("Filter by environment")
    param :content_view_id, String, :desc => N_("Filter by content view")
    param_group :search, Api::V2::ApiController
    def index
      respond(:collection => scoped_search(index_relation.uniq, :name, :asc))
    end

    def index_relation
      collection = System.readable
      collection = collection.where(:content_view_id => params[:content_view_id]) if params[:content_view_id]
      collection = collection.where(:id => Organization.find(params[:organization_id]).systems.map(&:id)) if params[:organization_id]
      collection = collection.where(:environment_id => params[:environment_id]) if params[:environment_id]
      collection = collection.where(:id => Pool.find(params['pool_id']).systems.map(&:id)) if params['pool_id']
      collection = collection.where(:uuid => params['uuid']) if params['uuid']
      collection = collection.where(:name => params['name']) if params['name']
      collection
    end

    api :PUT, "/systems/:id", N_("Update content host information"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    param :release_ver, String, :desc => N_("Release version of the content host")
    param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
    param :environment_id, String, :desc => N_("Specify the environment")
    param :content_view_id, String, :desc => N_("Specify the content view")
    param :host_collection_ids, Array, :desc => N_("Specify the host collections as an array")
    def update
      host_params = system_params_to_host_params(system_params(params))
      @system.foreman_host.update_attributes!(host_params)
      respond_for_update
    end

    api :GET, "/systems/:id", N_("Show a content host"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def show
      respond
    end

    api :GET, "/systems/:id/releases", N_("Show releases available for the content host"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    desc <<-DESC
      A hint for choosing the right value for the releaseVer param
    DESC
    def releases
      response = { :results => @system.available_releases,
                   :total => @system.available_releases.size,
                   :subtotal => @system.available_releases.size }
      respond_for_index :collection => response
    end

    private

    def system_params_to_host_params(sys_params)
      content_facet = {}
      subscription_facet = {}
      host_params = {}
      host_params[:host_collection_ids] = sys_params[:host_collection_ids] unless sys_params[:host_collection_ids].blank?

      content_facet[:lifecycle_environment_id] = sys_params[:environment_id]
      content_facet[:content_view_id] = sys_params[:content_view_id]
      host_params[:content_facet_attributes] = content_facet.compact! unless content_facet.compact.empty?

      subscription_facet[:service_level] = params[:service_level]
      subscription_facet[:release_version] = params[:release_ver]
      host_params[:subscription_facet_attributes] = subscription_facet.compact! unless subscription_facet.compact.empty?
      host_params
    end

    def find_system
      @system = System.where(:uuid => params[:id]).first
      @host = ::Host.where(:id => params[:id]).first
      if @system.nil? && @host.nil?
        Resources::Candlepin::Consumer.get params[:id] # check with candlepin if system is Gone, raises RestClient::Gone
        fail HttpErrors::NotFound, _("Couldn't find content host '%s'") % params[:id]
      elsif @system.nil?
        @system = @host.content_host
      end
    end

    def find_environment
      return unless params.key?(:environment_id)

      @environment = KTEnvironment.find(params[:environment_id])
      fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @organization = @environment.organization
      @environment
    end

    def find_host_collection
      return unless params.key?(:host_collection_id)

      @host_collection = HostCollection.find(params[:host_collection_id])
    end

    def find_environment_and_content_view_by_env_id
      # There are some scenarios (primarily create) where a system may be
      # created using the content_view_environment.cp_id which is the
      # equivalent of "environment_id"-"content_view_id".
      if params[:environment_id].is_a? String
        if !params.key?(:content_view_id)
          cve = ContentViewEnvironment.find_by!(:cp_id => params[:environment_id])
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

    def find_environment_and_content_view
      if params.key?(:environment_id)
        find_environment_and_content_view_by_env_id
      else
        @environment = @organization.library if @organization
      end
    end

    def find_content_view
      if (content_view_id = (params[:content_view_id] || params[:system].try(:[], :content_view_id)))
        setup_content_view(content_view_id)
      end
    end

    def system_params(param_hash)
      system_params = param_hash.require(:system).permit(:name, :location, :owner, :type,
                                                     :service_level, :autoheal,
                                                     :guest_ids, :host_collection_ids => [])

      system_params[:facts] = param_hash[:system][:facts].permit! if param_hash[:system][:facts]
      system_params[:type] = param_hash[:type] ? param_hash[:type] : ::Katello::Host::SubscriptionFacet::DEFAULT_TYPE

      { :guest_ids => :guestIds,
        :installed_products => :installedProducts,
        :release_ver => :releaseVer,
        :service_level => :serviceLevel,
        :last_checkin => :lastCheckin }.each do |snake, camel|
        if param_hash[snake]
          system_params[camel] = param_hash[snake]
        elsif param_hash[camel]
          system_params[camel] = param_hash[camel]
        end
      end
      system_params[:installedProducts] = [] if system_params.key?(:installedProducts) && system_params[:installedProducts].nil?

      unless User.consumer?
        system_params.merge!(param_hash[:system].permit(:environment_id, :content_view_id))
        system_params[:content_view_id] = nil if system_params[:content_view_id] == false
        system_params[:content_view_id] = param_hash[:system][:content_view][:id] if param_hash[:system][:content_view]
        system_params[:environment_id] = param_hash[:system][:environment][:id] if param_hash[:system][:environment]
      end

      system_params
    end

    def setup_content_view(cv_id)
      return if @content_view
      organization = @organization
      organization ||= @system.organization if @system
      organization ||= @environment.organization if @environment
      if cv_id && organization
        @content_view = ContentView.readable.find_by(:id => cv_id)
        fail HttpErrors::NotFound, _("Couldn't find content view '%s'") % cv_id if @content_view.nil?
      else
        @content_view = nil
      end
    end

    def authorize_environment
      return deny_access unless @environment.readable?
      true
    end
  end
end
