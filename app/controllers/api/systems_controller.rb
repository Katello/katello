#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::SystemsController < Api::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:create, :index, :activate]
  before_filter :find_organization, :only => [:create, :hypervisors_update, :index, :activate, :report, :tasks]
  before_filter :find_only_environment, :only => [:create]
  before_filter :find_environment, :only => [:create, :index, :report, :tasks]
  before_filter :find_environment_by_name, :only => [:hypervisors_update]
  before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates,
                                        :upload_package_profile, :errata, :package_profile, :subscribe,
                                        :unsubscribe, :subscriptions, :pools, :enabled_repos]
  before_filter :find_task, :only => [:task_show]
  before_filter :authorize, :except => :activate

  skip_before_filter :require_user, :only => [:activate]

  def rules
    index_systems = lambda { System.any_readable?(@organization) }
    register_system = lambda { System.registerable?(@environment, @organization) }
    consumer_only = lambda { User.consumer? }
    edit_system = lambda { @system.editable? or User.consumer? }
    read_system = lambda { @system.readable? or User.consumer? }
    delete_system = lambda { @system.deletable? or User.consumer? }

    # After a system registers, it immediately uploads its packages. Although newer subscription-managers send
    # certificate (User.consumer? == true), some do not. In this case, confirm that the user has permission to
    # register systems in the system's organization and environment.
    upload_system_packages = lambda { @system.editable? or System.registerable?(@system.environment, @system.organization) or User.consumer? }

    {
      :new => register_system,
      :create => register_system,
      :hypervisors_update => consumer_only,
      :regenerate_identity_certificates => edit_system,
      :update => edit_system,
      :index => index_systems,
      :show => read_system,
      :destroy => delete_system,
      :package_profile => read_system,
      :errata => read_system,
      :upload_package_profile => upload_system_packages,
      :report => index_systems,
      :subscribe => edit_system,
      :unsubscribe => edit_system,
      :subscriptions => read_system,
      :pools => read_system,
      :activate => register_system,
      :tasks => index_systems,
      :task_show => read_system,
      :enabled_repos => consumer_only
    }
  end

  def create
    system = System.create!(params.merge({:environment => @environment}))
    render :json => system.to_json
  end

  def hypervisors_update
    cp_response, hypervisors = System.register_hypervisors(@environment, params.except(:controller, :action))
    render :json => cp_response
  end

  # used for registering with activation keys
  def activate
    activation_keys = find_activation_keys
    User.current = activation_keys.first.user
    system = System.new(params.except(:activation_keys))
    # we apply ak in reverse order so when they conflict e.g. in environment, the first wins.
    activation_keys.reverse_each {|ak| ak.apply_to_system(system) }
    system.save!
    activation_keys.each {|ak| ak.subscribe_system(system) }
    render :json => system.to_json
  end

  def subscriptions
    render :json => @system.entitlements
  end

  def subscribe
    expected_params = params.with_indifferent_access.slice(:pool, :quantity)
    raise HttpErrors::BadRequest, _("Please provide pool and quantity") if expected_params.count != 2
    @system.subscribe(expected_params[:pool], expected_params[:quantity])
    render :json => @system.to_json
  end

  def unsubscribe
    expected_params = params.with_indifferent_access.slice(:pool)
    raise HttpErrors::BadRequest, _("Please provide pool id") if expected_params.count != 1
    @system.unsubscribe(expected_params[:serial_id])
    render :json => @system.to_json
  end

  def regenerate_identity_certificates
    @system.regenerate_identity_certificates
    render :json => @system.to_json
  end

  def update
    # not sure if this is the best way to do this...
    @system.description = params[:description] if params[:description]
    @system.name = params[:name] if params[:name]
    @system.location = params[:location] if params[:location]
    @system.facts = params[:facts] if params.has_key?(:facts)
    @system.guestIds = params[:guestIds] if params.has_key?(:guestIds)
    @system.installedProducts = params[:installedProducts] if params.has_key?(:installedProducts)

    @system.save!
    render :json => @system.to_json
  end

  def index
    # expected parameters
    expected_params = params.slice('name')
    error_msg = "No systems found" if expected_params.empty?
    error_msg = "Couldn't find system '#{expected_params[:name]}'" unless expected_params.empty?
    unless @environment.nil?
      systems = @environment.systems.readable(@organization).where(expected_params)
      raise HttpErrors::NotFound, _(error_msg + " in environment '#{@environment.name}'") if systems.empty?
    else
      systems = @organization.systems.readable(@organization).where(expected_params)
      raise HttpErrors::NotFound, _(error_msg + " in organization '#{@organization.name}'") if systems.empty?
    end
    render :json => systems.to_json
  end

  def show
    render :json => @system.to_json
  end

  def destroy
    @system.destroy
    render :text => _("Deleted system '#{params[:id]}'"), :status => 204
  end

  def pools
    listall = (params.has_key?(:listall) ? true : false)
    render :json => { :pools => @system.available_pools_full(listall) }
  end

  def package_profile
    render :json => @system.package_profile.sort {|a,b| a["name"].downcase <=> b["name"].downcase}.to_json
  end

  def errata
    render :json => Pulp::Consumer.errata(@system.uuid)
  end

  def upload_package_profile
    raise HttpErrors::BadRequest, _("No package profile received for #{@system.name}") unless params.has_key?(:_json)
    @system.upload_package_profile(params[:_json])
    render :json => @system.to_json
  end

  def report
    data = @environment.nil? ? @organization.systems.readable(@organization) : @environment.systems.readable(@organization)

    data = data.flatten.map do |r|
      r.reportable_data(
        :only => [:uuid, :name, :location, :created_at, :updated_at],
        :methods => [ :environment, :organization, :compliance_color, :compliant_until]
      )
    end.flatten!

    system_report = Ruport::Data::Table.new(
      :data => data,
      :column_names => ["name", "uuid", "location", "environment", "organization", "created_at", "updated_at", "compliance_color", "compliant_until"],
      :record_class => Ruport::Data::Record,
      :transforms => lambda {|r|
        r.organization = r.organization.name
        r.environment = r.environment.name
      })

    system_report.rename_column("environment.name", "environment")
    system_report.rename_column("created_at", "created")
    system_report.rename_column("updated_at", "updated")
    system_report.rename_column("compliance_color", "compliance")
    system_report.rename_column("compliant_until", "compliant until")

    pdf_options = {:table_format => {
      :heading_font_size => 10,
      :font_size => 8,
      :column_options => {
        "width" => 50,
        "name" => {"width" => 100},
        "uuid" => {"width" => 100},
        "location" => {"width" => 50},
        "environment" => {"width" => 40},
        "organization" => {"width" => 75},
        "created" => {"width" => 60},
        "updated" => {"width" => 60}
       }
    }}

    respond_to do |format|
      format.html { render :text => system_report.as(:html), :type => :html and return }
      format.text { render :text => system_report.as(:text, :ignore_table_width => true) }
      format.csv { render :text => system_report.as(:csv) }
      format.pdf { send_data(system_report.as(:pdf, pdf_options), :filename => "katello_systems_report.pdf", :type => "application/pdf") }
    end
  end

  def tasks
    @tasks = SystemTask.joins(:system,:task_status).where(:"task_statuses.organization_id" => @organization.id)
    if @environment
      @tasks = @tasks.where(:"system.environment_id" => @environment.id)
    end
    if params[:system_name]
      @tasks = @tasks.where(:"system.name" => params[:system_name])
    end
    @tasks.each {|t| t.task_status.refresh }
    render :json => @tasks.to_json
  end

  def task_show
    @task.task_status.refresh
    render :json => @task.to_json
  end

  def enabled_repos
    repos = params['enabled_repos'] rescue raise(HttpErrors::BadRequest, _("Expected attribute is missing:") + " enabled_repos")
    update_labels = repos['repos'].collect{ |r| r['repositoryid']} rescue raise(HttpErrors::BadRequest, _("Unable to parse repositories: #{$!}"))

    update_ids = []
    unknown_labels = []
    update_labels.each do |label|
      repo = @system.environment.repositories.find_by_cp_label label
      if repo.nil?
        logger.warn(_("Unknown repository label") + ": #{label}")
        unknown_labels << label
      else
        update_ids << repo.pulp_id
      end
    end

    processed_ids, error_ids = @system.enable_repos(update_ids)

    result = {}
    result[:processed_ids] = processed_ids
    result[:error_ids] = error_ids
    result[:unknown_labels] = unknown_labels
    if error_ids.count > 0 or unknown_labels.count > 0
      result[:result] = "error"
    else
      result[:result] = "ok"
    end

    render :json => result.to_json
  end

  protected

  def find_organization
    return unless (params.has_key?(:organization_id) or params.has_key?(:owner))

    id = (params[:organization_id] || params[:owner]).tr(' ', '_')
    @organization = Organization.first(:conditions => {:cp_key => id})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{id}'") if @organization.nil?
    @organization
  end

  def find_only_environment
    if !@environment && @organization && !params.has_key?(:environment_id)
      raise HttpErrors::BadRequest, _("Organization #{@organization.name} has 'Library' environment only. Please create an environment for system registration.") if @organization.environments.empty?

      # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
      # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
      # this scenario, if the org passed in matches the user's default org, use the default env. If not use
      # the single env of the org or throw an error if more than one.
      #
      if @organization.environments.size > 1
        if current_user.default_environment && current_user.default_environment.organization == @organization
          @environment = current_user.default_environment
        else
          raise HttpErrors::BadRequest, _("Organization #{@organization.name} has more than one environment. Please specify target environment for system registration.")
        end
      else
        @environment = @organization.environments.first and return
      end
    end
  end

  def find_environment_by_name
    @environment = @organization.environments.find_by_name!(params[:env])
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def verify_presence_of_organization_or_environment
    # This has to grab the first default org associated with this user AND
    # the environment that goes with him.
    return if params.has_key?(:organization_id) or params.has_key?(:owner) or params.has_key?(:environment_id)

    #At this point we know that they didn't supply an org or environment, so we can look up the default
    @environment = current_user.default_environment
    if @environment
      @organization = @environment.organization
    else
      raise _("You have not set a default organization and environment on the user #{current_user.username}.")
    end
  end

  def find_system
    @system = System.first(:conditions => {:uuid => params[:id]})
    raise HttpErrors::NotFound, _("Couldn't find system '#{params[:id]}'") if @system.nil?
    @system
  end

  def find_activation_keys
    if ak_names = params[:activation_keys]
      ak_names = ak_names.split(",")
      activation_keys = ak_names.map do |ak_name|
        activation_key = @organization.activation_keys.find_by_name(ak_name)
        raise HttpErrors::NotFound, _("Couldn't find activation key '#{ak_name}'") unless activation_key
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

  def find_task
    @task = SystemTask.joins(:task_status).where(:"task_statuses.uuid" => params[:id]).first
    raise ActiveRecord::RecordNotFound.new unless @task
    @system = @task.system
  end

end
