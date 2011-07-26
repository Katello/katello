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

class Api::ActivationKeysController < Api::ApiController
  respond_to :json

  before_filter :verify_presence_of_organization_or_environment, :only => [:index]
  before_filter :find_environment, :only => [:index, :create]
  before_filter :find_organization, :only => [:index]
  before_filter :find_activation_key, :only => [:show, :update, :destroy]

  def index
    query_params[:organization_id] = @organization.id unless @organization.nil?
    query_params[:environment_id] = @environment.id unless @environment.nil?

    render :json => ActivationKey.where(query_params)
  end

  def show
    render :json => @activation_key
  end

  def create
    created = ActivationKey.create!(params[:activation_key]) do |ak|
      ak.environment = @environment
      ak.organization = @environment.organization
    end
    render :json => created
  end

  def update
    @activation_key.update_attributes!(params[:activation_key])
    render :json => ActivationKey.find(@activation_key.id)
  end

  def destroy
    @activation_key.destroy
   render :text => _("Deleted activation key '#{params[:id]}'"), :status => 204
  end

  def find_environment
    return unless params.has_key?(:environment_id)

    @environment = KPEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

  def find_activation_key
    @activation_key = ActivationKey.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find activation_key '#{params[:id]}'") if @activation_key.nil?
    @activation_key
  end

  def verify_presence_of_organization_or_environment
    return if params.has_key?(:organization_id) or params.has_key?(:environment_id)
    raise HttpErrors::BadRequest, _("Either organization id or environment id needs to be specified")
  end
end
