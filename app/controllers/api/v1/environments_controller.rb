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

class Api::V1::EnvironmentsController < Api::V1::ApiController
  resource_description do
    description <<-EOS
      # Description

      An environment is a basic organization structure that groups systems,
      products, repositories, etc.  Every system belongs to one environment
      and it's isolated inside so that it can see only content that is in its
      environment.

      ## Chains

      Environments are ordered into chains and their content (propducts,
      repositories, tempaltes, packages) can be moved to an environment only from its
      prior environment. You can have for example chain like:

          Library -> Development -> Testing -> Production

      Each change in an environment is done through a changeset in an action
      called promotion.

      ## Library

      Library is a special environment that has no ascendant: all the content
      starts in this environment. More chains can start from the library environment but
      no further branching of a chain is enabled.
    EOS

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json
  before_filter :find_organization, :only => [:index, :rhsm_index, :create]
  before_filter :find_environment, :only => [:show, :update, :destroy, :repositories, :releases]
  before_filter :authorize

  def rules
    manage_rule = lambda{@organization.environments_manageable?}
    view_rule = lambda{@organization.readable?}

    index_rule = lambda {true}
    # Note: index_rule is always true.
    # Instead we are simply going to filter out the inaccessible environments
    # from the environment list we return. Look at the index method to
    # figure out how that rule is applied.

    {
      :index => index_rule,
      :rhsm_index => index_rule,
      :show => view_rule,
      :create => manage_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :repositories => view_rule,
      :releases => view_rule
    }
  end


  def param_rules
    {
      :create => {:environment =>  ["name", "label", "description", "prior" ]},
      :update => {:environment =>  ["name", "description", "prior" ]},
      :index => [:name, :library, :id, :organization_id],
      :rhsm_index => [:name, :library, :id, :organization_id]
    }
  end

  def_param_group :search_params do
    param :organization_id, :identifier, :desc => "organization identifier"
    param :library, :bool, :desc => "set true if you want to see only library environment"
    param :name, :identifier, :desc => "filter only environments with this identifier"
  end

  def_param_group :environment do
    param :environment, Hash, :required => true, :action_aware => true do
      param :name, :identifier, :desc => "name of the environment (identifier)", :required => true
      param :description, String
    end
  end

  api :GET, "/organizations/:organization_id/environments", "List environments in an organization"
  param_group :search_params
  def index
    query_params[:organization_id] = @organization.id
    @environments = KTEnvironment.where query_params

    # The following is a workaround to handle the fact that rhsm currently requests the
    # environment using the 'name' parameter; however, the value is actually the environment label.
    if @environments.empty?
      if query_params.has_key?(:name)
        query_params[:label] = query_params[:name]
        query_params.delete(:name)
      end
      @environments = KTEnvironment.where query_params
    end

    unless @organization.readable?
      @environments.delete_if do |env|
        !env.any_operation_readable?
      end
    end
    respond
  end

  api :GET, "/owners/:organization_id/environments", "List environments for RHSM"
  param_group :search_params
  def rhsm_index
    if query_params.has_key?(:name)
      # retrieve the requested environment
      @all_environments = get_content_view_environments(query_params[:name]).
                          collect{|env| {:id => env.cp_id, :name => env.label,
                                         :description => env.content_view.description}}
    else
      # retrieve the list of all environments
      @all_environments = get_content_view_environments.collect{|env| {:id => env.cp_id, :name => env.label,
                                                                      :description => env.content_view.description}}
    end
    respond_for_index :collection => @all_environments
  end

  api :GET, "/environments/:id", "Show an environment"
  api :GET, "/organizations/:organization_id/environments/:id", "Show an environment"
  param :id, :identifier, :desc => "environment identifier"
  param :organization_id, :identifier, :desc => "organization identifier"
  def show
    respond
  end

  api :POST, "/organizations/:organization_id/environments", "Create an environment in an organization"
  param :organization_id, :identifier, :desc => "organization identifier"
  param_group :environment
  param :environment, Hash, :required => true do
    param :prior, :identifier, :required => true, :desc => <<-DESC
        identifier of an environment that is prior the new environment in the chain, it has to be
        either library or an environment at the end of the chain
        DESC
  end
  def create
    environment_params = params[:environment]
    environment_params[:label] = labelize_params(environment_params)
    @environment = KTEnvironment.new(environment_params)
    @organization.environments << @environment
    raise ActiveRecord::RecordInvalid.new(@environment) unless @environment.valid?
    @organization.save!
    respond
  end

  api :PUT, "/environments/:id", "Update an environment"
  api :PUT, "/organizations/:organization_id/environments/:id", "Update an environment in an organization"
  param_group :environment
  def update
    raise HttpErrors::BadRequest, _("Can't update the '%s' environment") % "Library" if @environment.library?
    @environment.update_attributes!(params[:environment])
    respond
  end

  api :DELETE, "/environments/:id", "Destroy an environment"
  api :DELETE, "/organizations/:organization_id/environments/:id", "Destroy an environment in an organization"
  param :id, :identifier, :desc => "environment identifier"
  param :organization_id, :identifier, :desc => "organization identifier"
  def destroy
    if @environment.confirm_last_env
      @environment.destroy
      respond :message => _("Deleted environment '%s'") % params[:id]
    else
      raise HttpErrors::BadRequest,
            _("Environment %s has a successor. Only the last environment on a path can be deleted.") % @environment.name
    end
  end

  api :GET, "/organizations/:organization_id/environments/:id/repositories", "List repositories available in the environment"
  param :id, :identifier, :desc => "environment identifier"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :include_disabled, :bool, :desc => "set to true if you want to see also disabled repositories"
  def repositories
    @repositories = @environment.products.all_readable(@organization).collect { |p| p.repos(@environment, query_params[:include_disabled]) }.flatten
    respond_for_index :collection => @repositories
  end

  api :GET, "/environments/:id/releases", "List available releases for given environment"
  param :id, :identifier, :desc => "environment identifier"
  def releases
    render :json => { :releases => @environment.available_releases }
  end


  protected

  def find_environment
    @environment = KTEnvironment.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:id] if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def get_content_view_environments(name=nil)
    environments = ContentViewEnvironment.joins(:content_view => :organization).
        where("organizations.id = ?", @organization.id)
    environments = environments.where("content_view_environments.name = ?", name) if name

    if environments.empty?
      environments = ContentViewEnvironment.joins(:content_view => :organization).
          where("organizations.id = ?", @organization.id)
      environments = environments.where("content_view_environments.label = ?", name) if name
    end

    # remove any content view environments that aren't readable
    unless @organization.readable?
      environments.delete_if do |env|
        !env.content_view.readable?
      end
    end
    environments
  end

end
