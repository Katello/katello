#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::V1::SystemsController < Api::V1::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:create, :index, :activate]
  before_filter :find_optional_organization, :only => [:create, :hypervisors_update, :index, :activate, :report, :tasks]
  before_filter :find_only_environment, :only => [:create]
  before_filter :find_environment, :only => [:index, :report, :tasks]
  before_filter :find_environment_and_content_view, :only => [:create]
  before_filter :find_hypervisor_environment_and_content_view, :only => [:hypervisors_update]
  before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates,
                                        :upload_package_profile, :errata, :package_profile, :subscribe,
                                        :unsubscribe, :subscriptions, :pools, :enabled_repos, :releases,
                                        :add_system_groups, :remove_system_groups, :refresh_subscriptions, :checkin,
                                        :subscription_status]
  before_filter :find_content_view, :only => [:create, :update]
  before_filter :authorize, :except => :activate

  skip_before_filter :require_user, :only => [:activate]

  def organization_id_keys
    [:organization_id, :owner]
  end

  def rules
    index_systems          = lambda { System.any_readable?(@organization) }
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
        :tasks                            => index_systems,
        :task_show                        => read_system,
        :enabled_repos                    => consumer_only,
        :add_system_groups                => edit_system,
        :remove_system_groups             => edit_system,
        :refresh_subscriptions            => edit_system,
        :checkin                          => edit_system
    }
  end

  def_param_group :system do
    param :facts, Hash, :desc => "Key-value hash of system-specific facts", :action_aware => true
    param :installedProducts, Array, :desc => "List of products installed on the system", :action_aware => true
    param :name, String, :desc => "Name of the system", :required => true, :action_aware => true
    param :type, String, :desc => "Type of the system, it should always be 'system'", :required => true, :action_aware => true
    param :serviceLevel, String, :allow_nil => true, :desc => "A service level for auto-healing process, e.g. SELF-SUPPORT", :action_aware => true
    param :location, String, :desc => "Physical of the system"
    param :content_view_id, :identifier
    param :environment_id, :identifier
  end

  # this method is called from katello cli client and it does not work with activation keys
  # for activation keys there is method activate (see custom routes)
  api :POST, "/environments/:environment_id/consumers", "Register a system in environment (compatibility reason)"
  api :POST, "/environments/:environment_id/systems", "Register a system in environment"
  param_group :system
  def create
    @system = System.create!(params.merge({ :environment  => @environment,
                                            :content_view => @content_view,
                                            :serviceLevel => params[:service_level] }))
    respond_for_create
  end

  api :POST, "/hypervisors", "Update the hypervisors information for environment"
  desc <<DESC
Takes a hash representing the mapping: host system having geust systems, e.g.:

    { "host-uuid": ["guest-uuid-1", "guest-uuid-2"] }

See virt-who tool for more details.
DESC
  # TODO refactor render
  def hypervisors_update
    cp_response, hypervisors = System.register_hypervisors(@environment, @content_view, params.except(:controller, :action))
    render :json => cp_response
  end

  # used for registering with activation keys
  api :POST, "/consumers", "Register a system with activation key (compatibility)"
  api :POST, "/organizations/:organization_id/systems", "Register a system with activation key"
  param :activation_keys, String, :required => true
  param_group :system, :as => :create
  def activate
    # Activation keys are userless by definition so use the internal generic user
    # Set it before calling find_activation_keys to allow communication with candlepin
    User.current    = User.hidden.first
    activation_keys = find_activation_keys
    ActiveRecord::Base.transaction do
      # create new system entry
      @system = System.new(params.except(:activation_keys))

      # register system - we apply ak in reverse order so when they conflict e.g. in environment, the first wins.
      activation_keys.reverse_each { |ak| ak.apply_to_system(@system) }
      @system.save!

      # subscribe system - if anything goes wrong subscriptions are deleted in Candlepin and exception is rethrown
      activation_keys.each do |ak|
        ak.subscribe_system(@system)
        ak.system_groups.each do |group|
          group.system_ids = (group.system_ids + [@system.id]).uniq
          group.save!
        end
      end

      respond_for_create
    end
  end

  api :POST, "/consumers/:id", "Regenerate consumer identity"
  param :id, String, :desc => "UUID of the consumer"
  desc <<-DESC
Schedules the consumer identity certificate regeneration
  DESC
  def regenerate_identity_certificates
    @system.regenerate_identity_certificates
    respond_for_create
  end

  api :PUT, "/consumers/:id", "Update system information (compatibility)"
  api :PUT, "/systems/:id", "Update system information"
  param_group :system
  def update
    attrs = params.clone
    slice_attrs = [:name, :description, :location,
                   :facts, :guestIds, :installedProducts,
                   :releaseVer, :serviceLevel, :lastCheckin
                   ]
    unless User.consumer?
      slice_attrs =  slice_attrs + [:environment_id, :content_view_id]
      attrs[:content_view_id] = nil if attrs[:content_view_id] == false
      attrs[:content_view_id] = params[:content_view][:id] if params[:content_view]
      attrs[:environment_id] = params[:environment][:id] if params[:environment]
    end

    attrs[:installedProducts] = [] if attrs.has_key?(:installedProducts) && attrs[:installedProducts].nil?

    @system.update_attributes!(attrs.slice(*slice_attrs))

    respond
  end

  api :PUT, "/consumers/:id/checkin/", "Update system check-in time (compatibility)"
  api :PUT, "/systems/:id/checkin", "Update system check-in time"
  param :date, String, :desc => "check-in time"
  def checkin
    @system.checkin(params[:date])
    respond_for_show
  end

  api :GET, "/environments/:environment_id/consumers", "List systems (compatibilty)"
  api :GET, "/environments/:environment_id/systems", "List systems in environment"
  api :GET, "/organizations/:organization_id/systems", "List systems in organization"
  param :name, String, :desc => "Filter systems by name"
  param :pool_id, String, :desc => "Filter systems by subscribed pool"
  param :search, String, :desc => "Filter systems by advanced search query"
  def index
    query_string = params[:name] ? "name:#{params[:name]}" : params[:search]
    filters      = []

    if params[:env_id]
      find_environment
      filters << {:terms => {:environment_id => [params[:env_id]] }}
    else
      filters << readable_filters
    end

    filters << {:terms => {:uuid => System.all_by_pool_uuid(params['pool_id']) }} if params['pool_id']

    options = {
        :filters        => filters,
        :load_records? => true
    }
    options[:sort_by] = params[:sort_by] if params[:sort_by]
    options[:sort_order]= params[:sort_order] if params[:sort_order]

    if params[:paged]
      options[:page_size] = params[:page_size] || current_user.page_size
    end

    items = Glue::ElasticSearch::Items.new(System)
    systems, total_count = items.retrieve(query_string, params[:offset], options)

    if params[:paged]
      systems = {
        :results  => systems,
        :subtotal => total_count,
        :total    => items.total_items
      }
    end

    respond({ :collection => systems })
  end

  api :GET, "/consumers/:id", "Show a system (compatibility)"
  api :GET, "/systems/:id", "Show a system"
  param :id, String, :desc => "UUID of the system", :required => true
  def show
    respond
  end

  api :DELETE, "/consumers/:id", "Unregister a system (compatibility)"
  api :DELETE, "/systems/:id", "Unregister a system"
  param :id, String, :desc => "UUID of the system", :required => true
  def destroy
    @system.destroy
    respond :message => _("Deleted system '%s'") % params[:id], :status => 204
  end

  api :GET, "/systems/:id/subscription_status", "Show status of subscriptions on the system"
  param :id, String, :desc => "UUID of the system", :required => true
  def subscription_status
    respond_for_index :collection => @system.compliance
  end

  api :GET, "/systems/:id/pools", "List pools a system is subscribed to"
  param :id, String, :desc => "UUID of the system", :required => true
  def pools
    match_system    = params.has_key?(:match_system) ? params[:match_system].to_bool : false
    match_installed = params.has_key?(:match_installed) ? params[:match_installed].to_bool : false
    no_overlap      = params.has_key?(:no_overlap) ? params[:no_overlap].to_bool : false

    cp_pools = @system.filtered_pools(match_system, match_installed, no_overlap)

    respond_for_index :collection => { :pools => cp_pools }
  end

  api :GET, "/systems/:id/releases", "Show releases available for the system"
  param :id, String, :desc => "UUID of the system", :required => true
  desc <<-DESC
A hint for choosing the right value for the releaseVer param
  DESC
  def releases
    respond_for_index :collection => { :releases => @system.available_releases }
  end

  api :GET, "/systems/:id/packages", "List packages installed on the system"
  param :id, String, :desc => "UUID of the system", :required => true
  def package_profile
    respond_for_index :collection => @system.simple_packages.sort { |a, b| a.name.downcase <=> b.name.downcase }
  end

  api :GET, "/systems/:id/errata", "List errata available for the system"
  param :id, String, :desc => "UUID of the system", :required => true
  def errata
    respond_for_index :collection => @system.errata
  end

  api :PUT, "/consumers/:id/packages", "Update installed packages"
  api :PUT, "/consumers/:id/profile", "Update installed packages"
  param :id, String, :desc => "UUID of the system", :required => true
  def upload_package_profile
    if Katello.config.katello?
      raise HttpErrors::BadRequest, _("No package profile received for %s") % @system.name unless params.has_key?(:_json)
      @system.upload_package_profile(params[:_json])
    end
    respond_for_update
  end

  api :GET, "/environments/:environment_id/systems/report", "Get system reports for the environment"
  api :GET, "/organizations/:organization_id/systems/report", "Get system reports for the organization"
  def report
    data = @environment.nil? ? @organization.systems.readable(@organization) : @environment.systems.readable(@organization)

    data = data.flatten.map do |r|
      r.reportable_data(
          :only    => [:uuid, :name, :location, :created_at, :updated_at],
          :methods => [:environment, :organization, :compliance_color, :compliant_until, :custom_info]
      )
    end.flatten!

    system_report = Ruport::Data::Table.new(
        :data         => data,
        :column_names => ["name",
                          "uuid",
                          "location",
                          "organization",
                          "environment",
                          "created_at",
                          "updated_at",
                          "compliance_color",
                          "compliant_until",
                          "custom_info"
        ],
        :record_class => Ruport::Data::Record,
        :transforms   => lambda { |r|
          r.organization    = r.organization.name
          r.environment     = r.environment.name
          r.created_at      = r.created_at.to_s
          r.updated_at      = r.updated_at.to_s
          r.compliant_until = r.compliant_until.to_s
          r.custom_info     = r.custom_info.collect { |info| info.to_s }.join(", ")
        }
    )

    pdf_options = { :pdf_format   => {
        :page_layout => :portrait,
        :page_size   => "LETTER",
        :left_margin => 5
    },
                    :table_format => {
                        :width         => 585,
                        :cell_style    => { :size => 8 },
                        :row_colors    => ["FFFFFF", "F0F0F0"],
                        :column_widths => {
                            0 => 100,
                            1 => 100,
                            2 => 50,
                            3 => 40,
                            4 => 75,
                            5 => 60,
                            6 => 60 }
                    }
    }

    system_report.rename_column("created_at", "created")
    system_report.rename_column("updated_at", "updated")
    system_report.rename_column("compliance_color", "compliance")
    system_report.rename_column("compliant_until", "compliant until")
    system_report.rename_column("custom_info", "custom info")

    respond_to do |format|
      format.html do
        render :text => system_report.as(:html), :type => :html
        return
      end
      format.text { render :text => system_report.as(:text, :ignore_table_width => true) }
      format.csv { render :text => system_report.as(:csv) }
      format.pdf do
        send_data(
            system_report.as(:prawn_pdf, pdf_options),
            :filename => "%s_systems_report.pdf" % (Katello.config.katello? ? "katello" : "headpin"),
            :type     => "application/pdf"
        )
      end
    end
  end

  api :GET, "/organizations/:organization_id/systems/tasks", "List async tasks for the system"
  param :system_name, String, :desc => "Name of the system"
  param :system_uuid, String, :desc => "UUID of the system"
  def tasks
    query = TaskStatus.joins(:system).where(:"task_statuses.organization_id" => @organization.id)
    if @environment
      query = query.where(:"systems.environment_id" => @environment.id)
    end
    if params[:system_name]
      query = query.where(:"systems.name" => params[:system_name])
    elsif params[:system_uuid]
      query = query.where(:"systems.uuid" => params[:system_uuid])
    end

    task_ids = query.select('task_statuses.id')
    TaskStatus.refresh(task_ids)

    @tasks = TaskStatus.where(:id => task_ids)
    respond_for_index :collection => @tasks
  end

  api :PUT, "/systems/:id/enabled_repos", "Update the information about enabled repositories"
  desc <<-DESC
Used by katello-agent to keep the information about enabled repositories up to date.
This information is then used for computing the errata available for the system.
  DESC
  param :enabled_repos, Hash, :required => true do
    param :repos, Array, :required => true do
      params :baseurl, Array, :description=> "List of enabled repo urls for the repo (Only first is used.)", :required => false
    end
  end
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
    if error_ids.count > 0 || unknown_paths.count > 0
      result[:result] = "error"
    else
      result[:result] = "ok"
    end

    respond_for_show :resource => result
  end

  api :POST, "/systems/:id/system_groups", "Add a system to groups"
  param :system, Hash, :required => true do
    param :system_group_ids, Array, :desc => "List of group ids to add the system to", :required => true
  end
  def add_system_groups
    ids                      = params[:system][:system_group_ids]
    @system.system_group_ids = (@system.system_group_ids + ids).uniq
    @system.save!
    respond_for_create
  end

  api :DELETE, "/systems/:id/system_groups", "Remove a system from groups"
  param :system, Hash, :required => true do
    param :system_group_ids, Array, :desc => "List of group ids to add the system to", :required => true
  end
  def remove_system_groups
    ids                      = params[:system][:system_group_ids].map(&:to_i)
    @system.system_group_ids = (@system.system_group_ids - ids).uniq
    @system.save!
    respond_for_show
  end

  api :PUT, "/systems/:id/refresh_subscriptions", "Trigger a refresh of subscriptions, auto-attaching if enabled"
  param :id, String, :desc => "UUID of the system", :required => true
  def refresh_subscriptions
    @system.refresh_subscriptions
    respond_for_show
  end

  protected

  def find_only_environment
    if !@environment && @organization && !params.has_key?(:environment_id)
      raise HttpErrors::BadRequest, _("Organization %{org} has the '%{env}' environment only. Please create an environment for system registration.") % { :org => @organization.name, :env => "Library" } if @organization.environments.empty?

      # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
      # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
      # this scenario, if the org passed in matches the user's default org, use the default env. If not use
      # the single env of the org or throw an error if more than one.
      #
      if @organization.environments.size > 1
        if current_user.default_environment && current_user.default_environment.organization == @organization
          @environment = current_user.default_environment
        else
          raise HttpErrors::BadRequest, _("Organization %s has more than one environment. Please specify target environment for system registration.") % @organization.name
        end
      else
        if @environment = @organization.environments.first
          return
        end
      end
    end
  end

  def find_hypervisor_environment_and_content_view
    cve = get_content_view_environment_by_label(params[:env])
    @environment = cve.environment
    @content_view = cve.content_view
  end

  def get_content_view_environment_by_label(label)
    get_content_view_environment("label", label)
  end

  def get_content_view_environment(key, value)
    cve = nil
    if value
      cve = ContentViewEnvironment.where(key => value).first
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % value unless cve
      if @organization.nil? || !@organization.readable?
        unless cve.content_view.readable? || User.consumer?
          raise Errors::SecurityViolation, _("Could not access content view in environment '%s'") % value
        end
      end
    end
    cve
  end

  def get_content_view_environment_by_cp_id(id)
    get_content_view_environment("cp_id", id)
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def find_environment_and_content_view
    # There are some scenarios (primarily create) where a system may be
    # created using the content_view_environment.cp_id which is the
    # equivalent of "environment_id"-"content_view_id".
    return unless params.has_key?(:environment_id)

    if params[:environment_id].is_a? String
      if !params.has_key?(:content_view_id)
        cve = get_content_view_environment_by_cp_id(params[:environment_id])
        @environment = cve.environment
        @organization = @environment.organization
        @content_view = cve.content_view
      else
        # assumption here is :content_view_id is passed as a separate attrib
        @environment = KTEnvironment.find(params[:environment_id])
        @organization = @environment.organization
        raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      end
      return @environment, @content_view
    else
      find_environment
    end
  end

  def verify_presence_of_organization_or_environment
    # This has to grab the first default org associated with this user AND
    # the environment that goes with him.
    return if params.has_key?(:organization_id) || params.has_key?(:owner) || params.has_key?(:environment_id)

    #At this point we know that they didn't supply an org or environment, so we can look up the default
    @environment = current_user.default_environment
    if @environment
      @organization = @environment.organization
    else
      raise HttpErrors::NotFound, _("You have not set a default organization and environment on the user %s.") % current_user.username
    end
  end

  def find_system
    @system = System.first(:conditions => { :uuid => params[:id] })
    if @system.nil?
      Resources::Candlepin::Consumer.get params[:id] # check with candlepin if system is Gone, raises RestClient::Gone
      raise HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:id]
    end
    @system
  end

  def find_activation_keys
    if ak_names = params[:activation_keys]
      ak_names        = ak_names.split(",")
      activation_keys = ak_names.map do |ak_name|
        activation_key = @organization.activation_keys.find_by_name(ak_name)
        raise HttpErrors::NotFound, _("Couldn't find activation key '%s'") % ak_name unless activation_key
        activation_key
      end
    else
      activation_keys = []
    end
    if activation_keys.empty?
      raise HttpErrors::BadRequest, _("At least one activation key must be provided")
    end
    activation_keys
  end

  def readable_filters
    {:terms => {:environment_id => KTEnvironment.systems_readable(@organization).collect { |item| item.id } }}
  end

  def find_content_view
    if(content_view_id = (params[:content_view_id] || params[:system].try(:[], :content_view_id)))
      setup_content_view(content_view_id)
    end
  end

  def setup_content_view(cv_id)
    return if @content_view
    organization = @organization
    organization ||= @system.organization if @system
    organization ||= @environment.organization if @environment
    if cv_id && organization
      @content_view = ContentView.readable(organization).find_by_id(cv_id)
      raise HttpErrors::NotFound, _("Couldn't find content view '%s'") % cv_id if @content_view.nil?
    else
      @content_view = nil
    end
  end

  # to make sure that the changes are reflected to elasticsearch immediately
  # otherwise the index action doesn't have to know about the changes
  def refresh_index
    System.index.refresh if Katello.config.use_elasticsearch
  end

end
