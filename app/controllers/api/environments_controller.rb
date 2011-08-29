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
  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_environment, :only => [:show, :update, :destroy, :repositories]
  before_filter :authorize

  def rules
    manage_rule = lambda{@organization.environments_manageable?}
    view_rule = lambda{@organization.readable?}
    {
      :index => view_rule,
      :show => view_rule,
      :create => manage_rule,
      :update => manage_rule,
      :destroy => manage_rule,
      :repositories => view_rule
    }
  end

  def index
    query_params[:organization_id] = @organization.id
    render :json => (KTEnvironment.where query_params).to_json
  end

  def show
    render :json => @environment
  end

  def create
    environment = KTEnvironment.new(params[:environment])
    @organization.environments << environment
    @organization.save!
    render :json => environment
  end
  
  def update
    if @environment.locker?
      raise HttpErrors::BadRequest, _("Can't update Locker environment")
    else
      @environment.update_attributes!(params[:environment])
      render :json => @environment
    end
  end

  def destroy
    @environment.destroy
    render :text => _("Deleted environment '#{params[:id]}'"), :status => 200
  end

  def repositories
    render :json => @environment.products.readable.collect { |p| p.repos(@environment) }.flatten
  end

  def find_environment
    @environment = KTEnvironment.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:id]}'") if @environment.nil?
    @organization = @environment.organization
    @environment
  end
  
end
