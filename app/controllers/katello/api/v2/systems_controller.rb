# rubocop:disable SymbolName
module Katello
  class Api::V2::SystemsController < Api::V2::ApiController
    respond_to :json

    wrap_parameters :include => (System.attribute_names + %w(type autoheal facts guest_ids host_collection_ids installed_products content_view environment))

    skip_before_filter :set_default_response_format, :only => :report

    before_filter :find_system, :only => [:destroy, :show, :update,
                                          :package_profile,
                                          :pools, :enabled_repos, :releases,
                                          :available_host_collections,
                                          :refresh_subscriptions, :tasks, :content_override, :events]
    before_filter :find_environment, :only => [:index, :report]
    before_filter :find_optional_organization, :only => [:create, :index, :report]
    before_filter :find_host_collection, :only => [:index]
    before_filter :find_default_organization_and_or_environment, :only => [:create, :index]

    before_filter :find_environment_and_content_view, :only => [:create]
    before_filter :find_content_view, :only => [:create, :update]
    before_filter :load_search_service, :only => [:index, :available_host_collections, :tasks]
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
    api :GET, "/host_collections/:host_collection_id/systems", N_("List content hosts in a host collection"), :deprecated => true
    param :name, String, :desc => N_("Filter content host by name")
    param :pool_id, String, :desc => N_("Filter content host by subscribed pool")
    param :uuid, String, :desc => N_("Filter content host by uuid")
    param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
    param :environment_id, String, :desc => N_("Filter by environment")
    param :host_collection_id, String, :desc => N_("Filter by host collection")
    param :content_view_id, String, :desc => N_("Filter by content view")
    param :erratum_id, String, :desc => N_("Filter by systems that need an Erratum by uuid")
    param :errata_ids, Array, :desc => N_("Filter by systems that need any one of multiple Errata by uuid")
    param :erratum_restrict_installable, String, :desc => N_("Return only systems where the Erratum specified by erratum_id or errata_ids is available to systems (default False)")
    param :erratum_restrict_non_installable, String, :desc => N_("Return only systems where the Erratum specified by erratum_id or errata_ids is unavailable to systems (default False)")
    param_group :search, Api::V2::ApiController
    def index
      if params[:erratum_id] || params[:errata_ids]
        errata_ids = params.fetch(:errata_ids, [])
        errata_ids << params[:erratum_id] if params[:erratum_id]
        systems = systems_by_errata(errata_ids, params[:erratum_restrict_installable],
            params[:erratum_restrict_non_installable])
      else
        systems = System.readable
      end

      systems = systems.where(:content_view_id => params[:content_view_id]) if params[:content_view_id]
      filters = [{:terms => {:uuid => systems.pluck("#{Katello::System.table_name}.uuid").compact}}]
      environment_ids = params[:organization_id] ? Organization.find(params[:organization_id]).kt_environments.pluck(:id) : []
      environment_ids = environment_ids.empty? ? params[:environment_id] : environment_ids & [params[:environment_id].to_i] if params[:environment_id]
      unless environment_ids.empty?
        filters << {:terms => {:environment_id =>  environment_ids}}
      end
      if params[:host_collection_id]
        filters << {:terms => {:host_collection_ids => [params[:host_collection_id]] }}
      end
      if params[:activation_key_id]
        filters << {:terms => {:activation_key_ids => [params[:activation_key_id]] }}
      end

      filters << {:terms => {:uuid => System.all_by_pool_uuid(params['pool_id']) }} if params['pool_id']
      filters << {:terms => {:uuid => [params['uuid']] }} if params['uuid']
      filters << {:term => {:name => params['name'] }} if params['name']

      options = {
        :filters       => filters,
        :load_records? => true,
        :includes => [:content_view, :activation_keys, :environment]
      }
      respond_for_index(:collection => item_search(System, params, options))
    end

    api :POST, "/systems", N_("Register a content host"), :deprecated => true
    api :POST, "/environments/:environment_id/systems", N_("Register a content host in environment"), :deprecated => true
    api :POST, "/host_collections/:host_collection_id/systems", N_("Register a content host in environment"), :deprecated => true
    param :name, String, :desc => N_("Name of the content host"), :required => true, :action_aware => true
    param :description, String, :desc => N_("Description of the content host")
    param :location, String, :desc => N_("Physical location of the content host")
    param :facts, Hash, :desc => N_("Key-value hash of content host-specific facts"), :action_aware => true, :required => true do
      param :fact, String, :desc => N_("Any number of facts about this content host")
    end
    param :type, String, :desc => N_("Type of the content host, it should always be 'system'"), :required => true, :action_aware => true
    param :guest_ids, Array, :desc => N_("IDs of the virtual guests running on this content host")
    param :installed_products, Array, :desc => N_("List of products installed on the content host"), :action_aware => true
    param :release_ver, String, :desc => N_("Release version of the content host")
    param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
    param :last_checkin, String, :desc => N_("Last check-in time of this content host")
    param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
    param :environment_id, String, :desc => N_("Specify the environment")
    param :content_view_id, String, :desc => N_("Specify the content view")
    param :host_collection_ids, Array, :desc => N_("Specify the host collections as an array")
    def create
      @system = System.new(system_params(params).merge(:environment  => @environment,
                                                       :content_view => @content_view))
      sync_task(::Actions::Katello::System::Create, @system)
      @system.reload
      respond_for_create
    end

    api :PUT, "/systems/:id", N_("Update content host information"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    param :name, String, :desc => N_("Name of the content host"), :required => true, :action_aware => true
    param :description, String, :desc => N_("Description of the content host")
    param :location, String, :desc => N_("Physical location of the content host")
    param :facts, Hash, :desc => N_("Key-value hash of content host-specific facts"), :action_aware => true do
      param :fact, String, :desc => N_("Any number of facts about this content host")
    end
    param :type, String, :desc => N_("Type of the content host, it should always be 'system'"), :action_aware => true
    param :guest_ids, Array, :desc => N_("IDs of the virtual guests running on this content host")
    param :installed_products, Array, :desc => N_("List of products installed on the content host"), :action_aware => true
    param :release_ver, String, :desc => N_("Release version of the content host")
    param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
    param :last_checkin, String, :desc => N_("Last check-in time of this content host")
    param :environment_id, String, :desc => N_("Specify the environment")
    param :content_view_id, String, :desc => N_("Specify the content view")
    param :host_collection_ids, Array, :desc => N_("Specify the host collections as an array")
    def update
      system_params = system_params(params)
      sync_task(::Actions::Katello::System::Update, @system, system_params)
      respond_for_update
    end

    api :GET, "/systems/:id", N_("Show a content host"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def show
      @host_collections = @system.host_collections
      respond
    end

    api :GET, "/systems/:id/available_host_collections", N_("List host collections the content host does not belong to"), :deprecated => true
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => N_("host collection name to filter by")
    def available_host_collections
      system_org_id = @system.environment.organization_id
      pluck_val = "#{Katello::HostCollection.table_name}.id"
      filters = [:terms => {:id => HostCollection.readable.where(:organization_id => system_org_id).pluck(pluck_val) - @system.host_collection_ids}]
      filters << {:term => {:name => params[:name]}} if params[:name]

      options = {
        :filters       => filters,
        :load_records? => true
      }

      host_collections = item_search(HostCollection, params, options)
      respond_for_index(:collection => host_collections)
    end

    api :DELETE, "/systems/:id", N_("Unregister a content host"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def destroy
      sync_task(::Actions::Katello::System::Destroy, @system)
      respond :message => _("Deleted content host '%s'") % params[:id], :status => 204
    end

    api :GET, "/systems/:id/packages", N_("List packages installed on the content host"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def package_profile
      packages = @system.simple_packages.sort { |a, b| a.name.downcase <=> b.name.downcase }
      response = {
        :records  => packages,
        :subtotal => packages.size,
        :total    => packages.size
      }
      respond_for_index :collection => response
    end

    api :PUT, "/systems/:id/refresh_subscriptions", N_("Trigger a refresh of subscriptions, auto-attaching if enabled"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def refresh_subscriptions
      sync_task(::Actions::Katello::System::AutoAttachSubscriptions, @system)
      respond_for_show(:resource => @system)
    end

    # TODO: break this method up
    api :GET, "/environments/:environment_id/systems/report", N_("Get content host reports for the environment"), :deprecated => true
    api :GET, "/organizations/:organization_id/systems/report", N_("Get content host reports for the organization"), :deprecated => true
    def report # rubocop:disable MethodLength
      data = @environment.nil? ? @organization.systems.readable : @environment.systems.readable

      data = data.flatten.map do |r|
        r.reportable_data(
            :only    => [:uuid, :name, :location, :created_at, :updated_at],
            :methods => [:environment, :organization, :compliance_color, :compliant_until]
        )
      end

      system_report = Util::ReportTable.new(
          :data         => data,
          :column_names => %w(name uuid location organization environment created_at updated_at
                              compliance_color compliant_until),
          :transforms   => lambda do |r|
                             r.organization    = r.organization.name
                             r.environment     = r.environment.name
                             r.created_at      = r.created_at.to_s
                             r.updated_at      = r.updated_at.to_s
                             r.compliant_until = r.compliant_until.to_s
                           end
      )
      respond_to do |format|
        format.text { render :text => system_report.as(:text) }
        format.csv { render :text => system_report.as(:csv) }
      end
    end

    api :GET, "/systems/:id/pools", N_("List pools a content host is subscribed to"), :deprecated => true
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    param :match_system, [true, false], :desc => N_("Match pools to content host")
    param :match_installed, [true, false], :desc => N_("Match pools to installed")
    param :no_overlap, [true, false], :desc => N_("allow overlap")
    def pools
      match_system    = ::Foreman::Cast.to_bool(params[:match_system])
      match_installed = ::Foreman::Cast.to_bool(params[:match_installed])
      no_overlap      = ::Foreman::Cast.to_bool(params[:no_overlap])

      cp_pools = @system.filtered_pools(match_system, match_installed, no_overlap)
      response = { :records => cp_pools,
                   :total => cp_pools.size,
                   :subtotal => cp_pools.size }

      respond_for_index :collection => response
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

    def content_override
      content_override = params[:content_override]
      @system.set_content_override(content_override[:content_label],
                                   content_override[:name], content_override[:value]) if content_override
      respond_for_show
    end

    api :GET, "/systems/:id/events", N_("List Candlepin events for the content host")
    param :id, String, :desc => N_("UUID of the content host"), :required => true
    def events
      @events = @system.events.map { |e| OpenStruct.new(e) }
      respond_for_index :collection => @events
    end

    private

    def find_system
      @system = System.where(:uuid => params[:id]).first
      if @system.nil?
        Resources::Candlepin::Consumer.get params[:id] # check with candlepin if system is Gone, raises RestClient::Gone
        fail HttpErrors::NotFound, _("Couldn't find content host '%s'") % params[:id]
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
          cve = ContentViewEnvironment.find_by_cp_id!(params[:environment_id])
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
      system_params = param_hash.require(:system).permit(:name, :description, :location, :owner, :type,
                                                     :service_level, :autoheal,
                                                     :guest_ids, :host_collection_ids => [])

      system_params[:facts] = param_hash[:system][:facts].permit! if param_hash[:system][:facts]
      system_params[:cp_type] = param_hash[:type] ? param_hash[:type] : ::Katello::System::DEFAULT_CP_TYPE
      system_params.delete(:type) if param_hash[:system].key?(:type)

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
        @content_view = ContentView.readable.find_by_id(cv_id)
        fail HttpErrors::NotFound, _("Couldn't find content view '%s'") % cv_id if @content_view.nil?
      else
        @content_view = nil
      end
    end

    def systems_by_errata(errata_uuids, installable, non_installable)
      installable = ::Foreman::Cast.to_bool(installable)
      non_installable = ::Foreman::Cast.to_bool(non_installable)

      errata = Katello::Erratum.where(:uuid => errata_uuids)
      if errata.count != errata_uuids.count
        fail _("Unable to find errata with ids: %s.") % (errata_uuids - errata.pluck(:uuid)).join(", ")
      end

      if installable
        System.readable.with_installable_errata(errata)
      elsif non_installable
        System.readable.with_non_installable_errata(errata)
      else
        System.readable.with_applicable_errata(errata)
      end
    end

    def authorize_environment
      return deny_access unless @environment.readable?
      true
    end
  end
end
