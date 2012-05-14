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

class Api::EnvironmentsController < Api::ApiController
  respond_to :json
  before_filter :find_organization, :only => [:index, :search, :create]
  before_filter :find_environment, :only => [:show, :update, :destroy, :repositories, :releases]
  before_filter :find_environments, :only => [:search]
  before_filter :authorize
  def rules
    index_rule = lambda{@organization.readable? || @organization.any_systems_registerable?}
    manage_rule = lambda{@organization.environments_manageable?}
    view_rule = lambda{@organization.readable?}

    search_rule = lambda {true}

    {
      :index => index_rule,
      :search => search_rule,
      :show => view_rule,
      :create => manage_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :repositories => view_rule,
      :releases => view_rule
    }
  end

  def find_environments
    query_params[:organization_id] = @organization.id
    @environments = KTEnvironment.where query_params
    @environments.delete_if do |env|
      !env.any_operation_readable?
    end
  end

  def param_rules
    manage_match =  {:environment =>  ["name", "description", "prior" ]}

    {
      :create =>manage_match,
      :update => manage_match,
      :search => [:name, :library, :id, :organization_id]
    }
  end

  def search
    render :json => (@environments).to_json
  end
  def index
    render :json => (@organization.environments).to_json
  end

  def show
    render :json => @environment
  end

  def create
    environment = KTEnvironment.new(params[:environment])
    @organization.environments << environment
    raise ActiveRecord::RecordInvalid.new(environment) unless environment.valid?
    @organization.save!
    render :json => environment
  end

  def update
    if @environment.library?
      raise HttpErrors::BadRequest, _("Can't update Library environment")
    else
      @environment.update_attributes!(params[:environment])
      render :json => @environment
    end
  end

  def destroy
    if @environment.confirm_last_env
      @environment.destroy
      render :text => _("Deleted environment '#{params[:id]}'"), :status => 200
    else
      raise HttpErrors::BadRequest,
            _("Environment #{@environment.name} has a successor. Only the last environment on a path can be deleted.")
    end
  end

  def repositories
    render :json => @environment.products.all_readable(@organization).collect { |p| p.repos(@environment, query_params[:include_disabled]) }.flatten
  end

  def releases
    render :json => { :releases => @environment.available_releases }
  end


  protected

  def find_environment
    @environment = KTEnvironment.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:id]}'") if @environment.nil?
    @organization = @environment.organization
    @environment
  end

end
