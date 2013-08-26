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

class Api::V1::DistributorsController < Api::V1::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:create, :index, :activate]
  before_filter :find_optional_organization, :only => [:create, :hypervisors_update, :index, :activate, :report, :tasks]
  before_filter :find_only_environment, :only => [:create]
  before_filter :find_environment, :only => [:create, :index, :report, :tasks]
  before_filter :find_distributor, :only => [:destroy, :show, :update,
                                             :subscribe, :unsubscribe, :subscriptions, :pools, :export]
  before_filter :find_task, :only => [:task_show]
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
        :report        => index_distributors,
        :subscribe     => edit_distributor,
        :unsubscribe   => edit_distributor,
        :subscriptions => read_distributor,
        :pools         => read_distributor,
        :activate      => register_distributor,
        :tasks         => index_distributors,
        :task_show     => read_distributor,
        :export        => read_distributor
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
  end
  def create
    distributor_params           = params[:distributor]
    distributor_params[:facts]   ||= { 'sockets' => 0 } # facts not used for distributors
    distributor_params[:cp_type] = "candlepin"          # The 'candlepin' type is allowed to export a manifest
    @distributor                 = Distributor.create!(distributor_params.merge({ :environment  => @environment,
                                                                                  :content_view => @content_view,
                                                                                  :serviceLevel => distributor_params[:service_level] }))
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
    match_distributor = params.has_key?(:match_distributor) ? params[:match_distributor].to_bool : false
    match_installed   = params.has_key?(:match_installed) ? params[:match_installed].to_bool : false
    no_overlap        = params.has_key?(:no_overlap) ? params[:no_overlap].to_bool : false

    cp_pools = @distributor.filtered_pools(match_distributor, match_installed, no_overlap)

    respond_for_index :collection => { :pools => cp_pools }
  end

  api :GET, "/environments/:environment_id/distributors/report", "Get distributor reports for the environment"
  api :GET, "/organizations/:organization_id/distributors/report", "Get distributor reports for the organization"
  def report
    data = @environment.nil? ? @organization.distributors.readable(@organization) : @environment.distributors.readable(@organization)

    data = data.flatten.map do |r|
      r.reportable_data(
          :only    => [:uuid, :name, :location, :created_at, :updated_at],
          :methods => [:environment, :organization, :compliance_color, :compliant_until, :custom_info]
      )
    end.flatten!

    distributor_report = Ruport::Data::Table.new(
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

    distributor_report.rename_column("created_at", "created")
    distributor_report.rename_column("updated_at", "updated")
    distributor_report.rename_column("compliance_color", "compliance")
    distributor_report.rename_column("compliant_until", "compliant until")
    distributor_report.rename_column("custom_info", "custom info")

    respond_to do |format|
      format.html do
        render :text => distributor_report.as(:html), :type => :html
        return
      end
      format.text { render :text => distributor_report.as(:text, :ignore_table_width => true) }
      format.csv { render :text => distributor_report.as(:csv) }
      format.pdf do
        send_data(
            distributor_report.as(:prawn_pdf, pdf_options),
            :filename => "%s_distributors_report.pdf" % (Katello.config.katello? ? "katello" : "headpin"),
            :type     => "application/pdf"
        )
      end
    end
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

  protected

  def find_only_environment
    if !@environment && @organization && !params.has_key?(:environment_id)
      raise HttpErrors::BadRequest, _("Organization %{org} has the '%{env}' environment only. Please create an environment for distributor registration.") % { :org => @organization.name, :env => "Library" } if @organization.environments.empty?

      # Some subscription-managers will call /users/$user/owners to retrieve the orgs that a user belongs to.
      # Then, If there is just one org, that will be passed to the POST /api/consumers as the owner. To handle
      # this scenario, if the org passed in matches the user's default org, use the default env. If not use
      # the single env of the org or throw an error if more than one.
      #
      if @organization.environments.size > 1
        if current_user.default_environment && current_user.default_environment.organization == @organization
          @environment = current_user.default_environment
        else
          raise HttpErrors::BadRequest, _("Organization %s has more than one environment. Please specify target environment for distributor registration.") % @organization.name
        end
      else
        if @environment = @organization.environments.first
          return
        end
      end
    end
  end

  def find_environment_by_name
    @environment = @organization.environments.find_by_name!(params[:env])
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    @organization = @environment.organization
    @environment
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

  def find_distributor
    @distributor = Distributor.first(:conditions => { :uuid => params[:id] })
    if @distributor.nil?
      Resources::Candlepin::Consumer.get params[:id] # check with candlepin if distributor is Gone, raises RestClient::Gone
      raise HttpErrors::NotFound, _("Couldn't find distributor '%s'") % params[:id]
    end
    @distributor
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

  def find_task
    @task = TaskStatus.where(:uuid => params[:id]).first
    raise ActiveRecord::RecordNotFound.new unless @task
    @distributor = @task.task_owner
  end

end
