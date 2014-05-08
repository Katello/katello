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
class Api::V1::DistributorsController < Api::V1::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:create, :index, :activate]
  before_filter :find_optional_organization, :only => [:create, :hypervisors_update, :index, :activate, :tasks]
  before_filter :find_only_environment, :only => [:create]
  before_filter :find_environment, :only => [:create, :index, :tasks]
  before_filter :find_distributor, :only => [:destroy, :show, :update,
                                             :subscribe, :unsubscribe, :subscriptions, :pools, :export]
  before_filter :find_task, :only => [:task_show]
  before_filter :verify_valid_distributor_version, :only => [:create]
  before_filter :authorize, :except => :activate

  skip_before_filter :require_user, :only => [:activate]

  def organization_id_keys
    [:organization_id, :owner]
  end

  def rules
    index_distributors   = lambda { Distributor.any_readable?(@organization) }
    register_distributor = lambda { Distributor.registerable?(@environment, @organization) }
    edit_distributor     = lambda { @distributor.editable? || User.consumer? }
    read_distributor     = lambda { @distributor.readable? || User.consumer? }
    delete_distributor   = lambda { @distributor.deletable? || User.consumer? }

    {
        :new           => register_distributor,
        :create        => register_distributor,
        :update        => edit_distributor,
        :index         => index_distributors,
        :show          => read_distributor,
        :destroy       => delete_distributor,
        :subscribe     => edit_distributor,
        :unsubscribe   => edit_distributor,
        :subscriptions => read_distributor,
        :pools         => read_distributor,
        :activate      => register_distributor,
        :tasks         => index_distributors,
        :task_show     => read_distributor,
        :export        => read_distributor,
        :versions      => lambda { true }
    }
  end

  def_param_group :distributors do
    param :distributor, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "Name of the distributor", :required => true, :action_aware => true
      param :facts, Hash, :desc => "Key-value hash of distributor-specific facts"
      param :installedProducts, Array, :desc => "List of products installed on the distributor"
      param :serviceLevel, String, :allow_nil => true, :desc => "A service level for auto-healing process, e.g. SELF-SUPPORT"
      param :releaseVer, String, :desc => "Release of the os. The $releasever variable in repo url will be replaced with this value"
      param :location, String, :desc => "Physical of the distributor"
      param :capabilities, Array, :desc => "List of subscription capabilities"
    end
  end

  # this method is called from katello cli client and it does not work with activation keys
  # for activation keys there is method activate (see custom routes)
  api :POST, "/environments/:environment_id/distributors", "Register a distributor in environment"
  param_group :distributors
  param :distributor, Hash, :required => true, :action_aware => true do
    param :type, String, :desc => "Type of the distributor, it should always be 'distributor'", :required => true
    param :version, String, :desc => "Version of the distributor. Defaults to the latest if not given."
  end
  def create
    distributor_params = params[:distributor]

    distributor_params[:facts]   ||= { 'sockets' => 0, 'distributor_version' => (distributor_params[:version] || Distributor.latest_version) }
    distributor_params[:cp_type]   = "candlepin" # The 'candlepin' type is allowed to export a manifest
    @distributor                   = Distributor.create!(distributor_params.merge(:environment  => @environment,
                                                                                  :content_view => @content_view,
                                                                                  :serviceLevel => distributor_params[:service_level]))
    respond
  end

  api :PUT, "/distributors/:id", "Update distributor information"
  param_group :distributors
  param :capabilities, Array, :desc => "For backwards capability with Red Hat hosted candlepin - List of subscription capabilities"
  def update
    distributor_params = params[:distributor]
    distributor_params = params.slice(:capabilities) if distributor_params.nil?
    distributor_params = [] if distributor_params.nil?

    @distributor.update_attributes!(distributor_params.slice(:name, :description, :location, :facts, :guestIds, :installedProducts, :releaseVer, :serviceLevel, :environment_id, :capabilities))
    respond
  end

  api :GET, "/environments/:environment_id/distributors", "List distributors in environment"
  api :GET, "/organizations/:organization_id/distributors", "List distributors in organization"
  param :name, String, :desc => "Filter distributors by name"
  param :pool_id, String, :desc => "Filter distributors by subscribed pool"
  def index
    # expected parameters
    expected_params = params.slice(:name, :uuid)

    @distributors = (@environment.nil?) ? @organization.distributors : @environment.distributors
    @distributors = @distributors.all_by_pool(params['pool_id']) if params['pool_id']
    @distributors = @distributors.readable(@organization).where(expected_params)

    respond
  end

  api :GET, "/distributors/:id", "Show a distributor"
  param :id, String, :desc => "UUID of the distributor", :required => true
  def show
    respond
  end

  api :GET, "/distributors/:id/export", "Export distributor's manifest"
  param :id, String, :desc => "UUID of the distributor", :required => true
  def export
    filename = params[:filename]
    filename = 'manifest.zip' if filename.nil? || filename == ''

    data = @distributor.export
    send_data data,
              :filename => filename,
              :type     => 'application/xml'
  end

  api :DELETE, "/distributors/:id", "Unregister a distributor"
  param :id, String, :desc => "UUID of the distributor", :required => true
  def destroy
    @distributor.destroy
    respond :message => _("Deleted distributor '%s'") % params[:id]
  end

  api :GET, "/distributors/:id/pools", "List pools a distributor is subscribed to"
  param :id, String, :desc => "UUID of the distributor", :required => true
  def pools
    match_distributor = params.key?(:match_distributor) ? params[:match_distributor].to_bool : false
    match_installed   = params.key?(:match_installed) ? params[:match_installed].to_bool : false
    no_overlap        = params.key?(:no_overlap) ? params[:no_overlap].to_bool : false

    cp_pools = @distributor.filtered_pools(match_distributor, match_installed, no_overlap)

    respond_for_index :collection => { :pools => cp_pools }
  end

  api :GET, "/organizations/:organization_id/distributors/tasks", "List async tasks for the distributor"
  param :distributor_name, String, :desc => "Name of the distributor"
  param :distributor_uuid, String, :desc => "UUID of the distributor"
  def tasks
    query = TaskStatus.joins(:distributor).where(:"task_statuses.organization_id" => @organization.id)
    if @environment
      query = query.where(:"distributors.environment_id" => @environment.id)
    end
    if params[:distributor_name]
      query = query.where(:"distributors.name" => params[:distributor_name])
    elsif params[:distributor_uuid]
      query = query.where(:"distributors.uuid" => params[:distributor_uuid])
    end

    task_ids = query.select('task_statuses.id')
    TaskStatus.refresh(task_ids)

    @tasks = TaskStatus.where(:id => task_ids)
    respond_for_index :collection => @tasks
  end

  api :GET, "/distributors/tasks/:id", "Show details of the async task"
  param :id, String, :desc => "UUID of the task", :required => true
  def task_show
    @task.refresh
    respond_for_show :resource => @task
  end

  api :GET, "/distributor_versions", "Show the list of available distributor versions"
  def versions
    respond_for_index :collection => Distributor.available_versions
  end

  protected

  def find_only_environment
    if !@environment && @organization && !params.key?(:environment_id)
      if @organization.lifecycle_environments.empty?
        fail HttpErrors::BadRequest, _("Organization %{org} has the '%{env}' environment only. Please create an environment for distributor registration.") %
          { :org => @organization.name, :env => "Library" }
      end

      # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
      # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
      # this scenario, if the org passed in matches the user's default org, use the default env. If not use
      # the single env of the org or throw an error if more than one.
      #
      if @organization.lifecycle_environments.size > 1
        if current_user.default_environment && current_user.default_environment.organization == @organization
          @environment = current_user.default_environment
        else
          fail HttpErrors::BadRequest, _("Organization %s has more than one environment. Please specify target environment for distributor registration.") % @organization.name
        end
      else
        if @environment = @organization.lifecycle_environments.first
          return
        end
      end
    end
  end

  def find_environment_by_name
    @environment = @organization.lifecycle_environments.find_by_name!(params[:env])
  end

  def find_environment
    return unless params.key?(:environment_id)

    @environment = LifecycleEnvironment.find(params[:environment_id])
    fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def verify_presence_of_organization_or_environment
    # This has to grab the first default org associated with this user AND
    # the environment that goes with him.
    return if params.key?(:organization_id) || params.key?(:owner) || params.key?(:environment_id)

    #At this point we know that they didn't supply an org or environment, so we can look up the default
    @environment = current_user.default_environment
    if @environment
      @organization = @environment.organization
    else
      fail HttpErrors::NotFound, _("You have not set a default organization and environment on the user %s.") % current_user.login
    end
  end

  def find_distributor
    @distributor = Distributor.first(:conditions => { :uuid => params[:id] })
    if @distributor.nil?
      Resources::Candlepin::Consumer.get params[:id] # check with candlepin if distributor is Gone, raises RestClient::Gone
      fail HttpErrors::NotFound, _("Couldn't find distributor '%s'") % params[:id]
    end
    @distributor
  end

  def find_activation_keys
    if ak_names = params[:activation_keys]
      ak_names         = ak_names.split(",")
      activation_keys  = ak_names.map do |ak_name|
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

  def find_task
    @task = TaskStatus.where(:uuid => params[:id]).first
    fail ActiveRecord::RecordNotFound.new unless @task
    @distributor = @task.task_owner
  end

  def verify_valid_distributor_version
    if params[:distributor][:version].present?
      dist_versions = Distributor.available_versions.collect { |v| v["name"] }
      unless dist_versions.include?(params[:distributor][:version])
        fail HttpErrors::BadRequest, _("Must specify a valid distributor version [ %s ].") % dist_versions.join(", ")
      end
    end
  end

end
end
