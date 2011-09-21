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
  before_filter :find_organization, :only => [:create, :index, :activate]
  before_filter :find_only_environment, :only => [:create]
  before_filter :find_environment, :only => [:create, :index]
  before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates, :upload_package_profile, :errata, :package_profile]
  before_filter :authorize, :except => :activate

  skip_before_filter :require_user, :only => [:activate]

  def rules
    index_systems = lambda { System.any_readable?(@organization) }
    register_system = lambda { System.registrable?(@environment, @organization) }
    edit_system = lambda { @system.editable? or User.consumer? }
    read_system = lambda { @system.readable? or User.consumer? }
    delete_system = lambda { @system.deletable? or User.consumer? }

    {
      :create => register_system,
      :regenerate_identity_certificates => edit_system,
      :update => edit_system,
      :index => index_systems,
      :show => read_system,
      :destroy => delete_system,
      :package_profile => read_system,
      :errata => read_system,
      :upload_package_profile => edit_system,
    }
  end

  def create
    system = System.create!(params.merge({:environment => @environment}))
    render :json => system.to_json
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

  def package_profile
    render :json => @system.package_profile.sort {|a,b| a["name"].downcase <=> b["name"].downcase}.to_json
  end
  
  def errata
    render :json => Pulp::Consumer.errata(@system.uuid)
  end
  
  def upload_package_profile
    raise HttpError::BadRequest, _("No package profile received for #{@system.name}") unless params.has_key?(:_json)
    @system.upload_package_profile(params[:_json])
    render :json => @system.to_json
  end

  def find_organization
    return unless (params.has_key?(:organization_id) or params.has_key?(:owner))

    id = (params[:organization_id] || params[:owner]).tr(' ', '_')
    @organization = Organization.first(:conditions => {:cp_key => id})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{id}'") if @organization.nil?
    @organization
  end

  def find_only_environment
    if @organization && !params.has_key?(:environment_id)
      raise HttpErrors::BadRequest, _("Organization #{@organization.name} has 'Locker' environment only. Please create an environment for system registration.") if @organization.environments.empty?
      raise HttpErrors::BadRequest, _("Organization #{@organization.name} has more than one environment. Please specify target environment for system registration.") if @organization.environments.size > 1
      @environment = @organization.environments.first and return
    end
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def verify_presence_of_organization_or_environment
    return if params.has_key?(:organization_id) or params.has_key?(:owner) or params.has_key?(:environment_id)
    raise HttpErrors::BadRequest, _("Either organization id or environment id needs to be specified")
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

end
