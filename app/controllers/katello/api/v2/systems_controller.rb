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

# rubocop:disable SymbolName
module Katello
class Api::V2::SystemsController < Api::V2::ApiController
  respond_to :json

  wrap_parameters :include => (System.attribute_names + %w(type facts guest_ids host_collection_ids installed_products content_view environment))

  skip_before_filter :set_default_response_format, :only => :report

  before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates,
                                        :upload_package_profile, :errata, :package_profile, :subscribe,
                                        :unsubscribe, :subscriptions, :pools, :enabled_repos, :releases,
                                        :available_host_collections, :add_host_collections, :remove_host_collections,
                                        :refresh_subscriptions, :checkin,
                                        :subscription_status, :tasks] # TODO: this should probably be :except
  before_filter :find_environment, :only => [:index, :report]
  before_filter :find_optional_organization, :only => [:create, :hypervisors_update, :index, :activate, :report]
  before_filter :find_host_collection, :only => [:index]
  before_filter :find_default_organization_and_or_environment, :only => [:create, :index, :activate]
  before_filter :find_only_environment, :only => [:create]

  before_filter :authorize, :except => [:activate, :upload_package_profile]

  before_filter :find_environment_and_content_view, :only => [:create]
  before_filter :find_hypervisor_environment_and_content_view, :only => [:hypervisors_update]
  before_filter :find_content_view, :only => [:create, :update]

  before_filter :load_search_service, :only => [:index, :available_host_collections, :tasks]

  def organization_id_keys
    [:organization_id, :owner]
  end

  # TODO: break up this method
  # rubocop:disable MethodLength
  def rules
    index_systems          = index_systems_perms_check
    register_system        = lambda { System.registerable?(@environment, @organization, @content_view) }
    consumer_only          = lambda { User.consumer? }
    edit_system            = lambda do
      subscribable = @content_view ? @content_view.subscribable? : true
      subscribable && (@system.editable? || User.consumer?)
    end
    read_system            = lambda { @system.readable? || User.consumer? }
    delete_system          = lambda { @system.deletable? || User.consumer? }

    # After a system registers, it immediately uploads its packages. Although newer subscription-managers send
    # certificate (User.consumer? == true), some do not. In this case, confirm that the user has permission to
    # register systems in the system's organization and environment.
   upload_system_packages = lambda { @system.editable? || System.registerable?(@system.environment, @system.organization) || User.consumer? }

    {
        :new                              => register_system,
        :create                           => register_system,
        :hypervisors_update               => consumer_only,
        :regenerate_identity_certificates => edit_system,
        :update                           => edit_system,
        :index                            => index_systems,
        :show                             => read_system,
        :subscription_status              => read_system,
        :destroy                          => delete_system,
        :package_profile                  => read_system,
        :errata                           => read_system,
        :upload_package_profile           => upload_system_packages,
        :report                           => index_systems,
        :subscribe                        => edit_system,
        :unsubscribe                      => edit_system,
        :subscriptions                    => read_system,
        :pools                            => read_system,
        :releases                         => read_system,
        :activate                         => register_system,
        :tasks                            => lambda { @system.readable? },
        :task_show                        => read_system,
        :enabled_repos                    => consumer_only,
        :available_host_collections          => edit_system,
        :add_host_collections                => edit_system,
        :remove_host_collections             => edit_system,
        :refresh_subscriptions            => edit_system,
        :checkin                          => edit_system
    }
  end

  def_param_group :system do
    param :facts, Hash, :desc => N_("Key-value hash of system-specific facts"), :action_aware => true do
      param :fact, String, :desc => N_("Any number of facts about this system")
    end
    param :installed_products, Array, :desc => N_("List of products installed on the system"), :action_aware => true
    param :name, String, :desc => N_("Name of the system"), :required => true, :action_aware => true
    param :type, String, :desc => N_("Type of the system, it should always be 'system'"), :required => true, :action_aware => true
    param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
    param :location, String, :desc => N_("Physical location of the system")
    param :content_view_id, :identifier
    param :environment_id, :identifier
  end

  api :GET, "/systems", N_("List systems")
  api :GET, "/organizations/:organization_id/systems", N_("List systems in an organization")
  api :GET, "/environments/:environment_id/systems", N_("List systems in environment")
  api :GET, "/host_collections/:host_collection_id/systems", N_("List systems in a host collection")
  param :name, String, :desc => N_("Filter systems by name")
  param :pool_id, String, :desc => N_("Filter systems by subscribed pool")
  param :uuid, String, :desc => N_("Filter systems by uuid")
  param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
  param :environment_id, String, :desc => N_("Filter by environment")
  param :host_collection_id, String, :desc => N_("Filter by host collection")
  param_group :search, Api::V2::ApiController
  def index
    filters = []

    if params[:environment_id]
      filters << {:terms => {:environment_id => [params[:environment_id]] }}
    elsif params[:host_collection_id]
      filters << {:terms => {:host_collection_ids => [params[:host_collection_id]] }}
    else
      filters << readable_filters
    end

    filters << {:terms => {:uuid => System.all_by_pool_uuid(params['pool_id']) }} if params['pool_id']
    filters << {:terms => {:uuid => [params['uuid']] }} if params['uuid']

    options = {
        :filters       => filters,
        :load_records? => true
    }
    respond_for_index(:collection => item_search(System, params, options))
  end

  api :POST, "/systems", N_("Register a system")
  api :POST, "/environments/:environment_id/systems", N_("Register a system in environment")
  api :POST, "/host_collections/:host_collection_id/systems", N_("Register a system in environment")
  param :name, String, :desc => N_("Name of the system"), :required => true, :action_aware => true
  param :description, String, :desc => N_("Description of the system")
  param :location, String, :desc => N_("Physical location of the system")
  param :facts, Hash, :desc => N_("Key-value hash of system-specific facts"), :action_aware => true, :required => true do
    param :fact, String, :desc => N_("Any number of facts about this system")
  end
  param :type, String, :desc => N_("Type of the system, it should always be 'system'"), :required => true, :action_aware => true
  param :guest_ids, Array, :desc => N_("IDs of the guests running on this system")
  param :installed_products, Array, :desc => N_("List of products installed on the system"), :action_aware => true
  param :release_ver, String, :desc => N_("Release version of the system")
  param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
  param :last_checkin, String, :desc => N_("Last check-in time of this system")
  param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
  param :environment_id, String, :desc => N_("Specify the environment")
  param :content_view_id, String, :desc => N_("Specify the content view")
  param :host_collection_id, String, :desc => N_("Specify the host collection")
  def create
    @system = System.new(system_params(params).merge(:environment  => @environment,
                                                     :content_view => @content_view))
    sync_task(::Actions::Katello::System::Create, @system)
    @system.reload
    respond_for_create
  end

  api :PUT, "/systems/:id", N_("Update system information")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  param :name, String, :desc => N_("Name of the system"), :required => true, :action_aware => true
  param :description, String, :desc => N_("Description of the system")
  param :location, String, :desc => N_("Physical location of the system")
  param :facts, Hash, :desc => N_("Key-value hash of system-specific facts"), :action_aware => true, :required => true do
    param :fact, String, :desc => N_("Any number of facts about this system")
  end
  param :type, String, :desc => N_("Type of the system, it should always be 'system'"), :required => true, :action_aware => true
  param :guest_ids, Array, :desc => N_("IDs of the guests running on this system")
  param :installed_products, Array, :desc => N_("List of products installed on the system"), :action_aware => true
  param :release_ver, String, :desc => N_("Release version of the system")
  param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
  param :last_checkin, String, :desc => N_("Last check-in time of this system")
  param :environment_id, String, :desc => N_("Specify the environment")
  param :content_view_id, String, :desc => N_("Specify the content view")
  def update
    @system.update_attributes!(system_params(params))

    respond_for_update
  end

  api :GET, "/systems/:id", N_("Show a system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def show
    @host_collections = @system.host_collections
    @custom_info = @system.custom_info
    respond
  end

  api :GET, "/systems/:id/available_host_collections", N_("List host collections the system does not belong to")
  param_group :search, Api::V2::ApiController
  param :name, String, :desc => N_("host collection name to filter by")
  def available_host_collections
    filters = [:terms => {:id => HostCollection.readable(@system.organization).pluck("#{Katello::HostCollection.table_name}.id") - @system.host_collection_ids}]
    filters << {:term => {:name => params[:name].downcase}} if params[:name]

    options = {
        :filters       => filters,
        :load_records? => true
    }

    host_collections = item_search(HostCollection, params, options)
    respond_for_index(:collection => host_collections)
  end

  api :DELETE, "/systems/:id", N_("Unregister a system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def destroy
    @system.destroy
    respond :message => _("Deleted system '%s'") % params[:id], :status => 204
  end

  api :GET, "/systems/:id/packages", N_("List packages installed on the system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def package_profile
    packages = @system.simple_packages.sort { |a, b| a.name.downcase <=> b.name.downcase }
    response = {
      :records  => packages,
      :subtotal => packages.size,
      :total    => packages.size
    }
    respond_for_index :collection => response
  end

  api :PUT, "/systems/:id/refresh_subscriptions", N_("Trigger a refresh of subscriptions, auto-attaching if enabled")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def refresh_subscriptions
    @system.refresh_subscriptions
    respond_for_show(:resource => @system)
  end

  api :GET, "/systems/:id/errata", N_("List errata available for the system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def errata
    errata = @system.errata
    response = {
      :records  => errata.sort_by{ |e| e.issued }.reverse,
      :subtotal => errata.size,
      :total    => errata.size
    }

    respond_for_index :collection => response
  end

  api :GET, "/systems/:id/tasks", N_("List async tasks for the system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  def tasks
    @system.refresh_tasks

    filters = [{:terms => {:task_owner_id => [@system.id]}},
               {:terms => {:task_owner_type => ["System"]}}]

    options = { :filters       => filters,
                :load_records? => true }

    respond_for_index(:collection => item_search(TaskStatus, params, options))
  end

  # TODO: break this mehtod up
  api :GET, "/environments/:environment_id/systems/report", N_("Get system reports for the environment")
  api :GET, "/organizations/:organization_id/systems/report", N_("Get system reports for the organization")
  def report # rubocop:disable MethodLength
    data = @environment.nil? ? @organization.systems.readable(@organization) : @environment.systems.readable(@organization)

    data = data.flatten.map do |r|
      r.reportable_data(
          :only    => [:uuid, :name, :location, :created_at, :updated_at],
          :methods => [:environment, :organization, :compliance_color, :compliant_until, :custom_info]
      )
    end

    system_report = Util::ReportTable.new(
        :data         => data,
        :column_names => %w(name uuid location organization environment created_at updated_at
                            compliance_color compliant_until custom_info),
        :transforms   => lambda do |r|
                           r.organization    = r.organization.name
                           r.environment     = r.environment.name
                           r.created_at      = r.created_at.to_s
                           r.updated_at      = r.updated_at.to_s
                           r.compliant_until = r.compliant_until.to_s
                           r.custom_info     = r.custom_info.collect { |info| info.to_s }.join(", ")
                         end
    )
    respond_to do |format|
      format.text { render :text => system_report.as(:text) }
      format.csv { render :text => system_report.as(:csv) }
    end
  end

  api :GET, "/systems/:id/pools", N_("List pools a system is subscribed to")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  param :match_system, [true, false], :desc => N_("Match pools to system")
  param :match_installed, [true, false], :desc => N_("Match pools to installed")
  param :no_overlap, [true, false], :desc => N_("allow overlap")
  def pools
    match_system    = params.key?(:match_system) ? params[:match_system].to_bool : false
    match_installed = params.key?(:match_installed) ? params[:match_installed].to_bool : false
    no_overlap      = params.key?(:no_overlap) ? params[:no_overlap].to_bool : false

    cp_pools = @system.filtered_pools(match_system, match_installed, no_overlap)
    response = { :records => cp_pools,
                 :total => cp_pools.size,
                 :subtotal => cp_pools.size }

    respond_for_index :collection => response
  end

  api :GET, "/systems/:id/releases", N_("Show releases available for the system")
  param :id, String, :desc => N_("UUID of the system"), :required => true
  desc <<-DESC
    A hint for choosing the right value for the releaseVer param
  DESC
  def releases
    response = { :results => @system.available_releases,
                 :total => @system.available_releases.size,
                 :subtotal => @system.available_releases.size }
    respond_for_index :collection => response
  end

  # used for registering with activation keys
  api :POST, "/organizations/:organization_id/systems", N_("Register a system with activation key")
  param :name, String, :desc => N_("Name of the system"), :required => true, :action_aware => true
  param :description, String, :desc => N_("Description of the system")
  param :location, String, :desc => N_("Physical location of the system")
  param :facts, Hash, :desc => N_("Key-value hash of system-specific facts"), :action_aware => true, :required => true do
    param :fact, String, :desc => N_("Any number of facts about this system")
  end
  param :type, String, :desc => N_("Type of the system, it should always be 'system'"), :required => true, :action_aware => true
  param :guest_ids, Array, :desc => N_("IDs of the guests running on this system")
  param :installed_products, Array, :desc => N_("List of products installed on the system"), :action_aware => true
  param :release_ver, String, :desc => N_("Release version of the system")
  param :service_level, String, :allow_nil => true, :desc => N_("A service level for auto-healing process, e.g. SELF-SUPPORT"), :action_aware => true
  param :last_checkin, String, :desc => N_("Last check-in time of this system")
  param :organization_id, :number, :desc => N_("Specify the organization"), :required => true
  param :environment_id, String, :desc => N_("Specify the environment")
  param :content_view_id, String, :desc => N_("Specify the content view")
  param :host_collection_id, String, :desc => N_("Specify the host collection")
  param :activation_keys, String, :desc => N_("comma-separated list of activation-key IDs"), :required => true
  def activate
    # Activation keys are userless by definition so use the internal generic user
    # Set it before calling find_activation_keys to allow communication with candlepin
    User.current    = User.hidden.first
    activation_keys = find_activation_keys
    ActiveRecord::Base.transaction do
      # create new system entry
      @system = System.new(system_params)

      # register system - we apply ak in reverse order so when they conflict e.g. in environment, the first wins.
      activation_keys.reverse_each { |ak| ak.apply_to_system(@system) }
      @system.save!

      # subscribe system - if anything goes wrong subscriptions are deleted in Candlepin and exception is rethrown
      activation_keys.each do |ak|
        ak.subscribe_system(@system)
        ak.host_collections.each do |host_collection|
          host_collection.system_ids = (host_collection.system_ids + [@system.id]).uniq
          host_collection.save!
        end
      end

      respond_for_create
    end
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

  private

  def find_system
    @system = System.first(:conditions => { :uuid => params[:id] })
    if @system.nil?
      Resources::Candlepin::Consumer.get params[:id] # check with candlepin if system is Gone, raises RestClient::Gone
      fail HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:id]
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

  def find_content_view
    if (content_view_id = (params[:content_view_id] || params[:system].try(:[], :content_view_id)))
      setup_content_view(content_view_id)
    end
  end

  def readable_filters
    {:terms => {:environment_id => KTEnvironment.systems_readable(@organization).collect { |item| item.id } }}
  end

  def index_systems_perms_check
    lambda do
      perms = [(System.any_readable?(@organization) if @organization),
               (System.any_readable?(@environment) if @environment),
               (System.any_readable?(@host_collection.organization) if @host_collection)]
      perms.compact.inject { |t, v| t && v }
    end
  end

  def system_params(params)
    system_params = params.require(:system).permit(:name, :description, :location, :owner, :type,
                                                   :service_level, {:facts => []},
                                                   :guest_ids, {:host_collection_ids => []})

    if params[:system].key?(:type)
      system_params[:cp_type] = params[:type]
      system_params.delete(:type)
    end

    # TODO: permit :facts above not working, why?
    system_params[:facts] = params[:facts] if params[:facts]

    { :guest_ids => :guestIds,
      :installed_products => :installedProducts,
      :release_ver => :releaseVer,
      :service_level => :serviceLevel,
      :last_checkin => :lastCheckin }.each do |snake, camel|
      if params[snake]
        system_params[camel] = params[snake]
      elsif params[camel]
        system_params[camel] = params[camel]
      end
    end
    system_params[:installedProducts] = [] if system_params.key?(:installedProducts) && system_params[:installedProducts].nil?

    unless User.consumer?
      system_params.merge!(params[:system].permit(:environment_id, :content_view_id))
      system_params[:content_view_id] = nil if system_params[:content_view_id] == false
      system_params[:content_view_id] = params[:system][:content_view][:id] if params[:system][:content_view]
      system_params[:environment_id] = params[:system][:environment][:id] if params[:system][:environment]
    end

    system_params
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

  def setup_content_view(cv_id)
    return if @content_view
    organization = @organization
    organization ||= @system.organization if @system
    organization ||= @environment.organization if @environment
    if cv_id && organization
      @content_view = ContentView.readable(organization).find_by_id(cv_id)
      fail HttpErrors::NotFound, _("Couldn't find content view '%s'") % cv_id if @content_view.nil?
    else
      @content_view = nil
    end
  end

end
end
