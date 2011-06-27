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

  before_filter :find_organization, :only => [:index]
  before_filter :find_environment, :only => [:create, :index]
  before_filter :verify_presence_of_organization_or_environment, :only => [:create, :index]
  before_filter :find_system, :only => [:destroy, :show, :update, :regenerate_identity_certificates]

  def create
    org = Organization.find_by_cp_key(params[:org_name])
    raise _("Couldn't find organization '#{params[:org_name]}'") if org.nil?
    system = System.create!(params.merge({:organization => org})).to_json
    render :json => system
  end

  def regenerate_identity_certificates
    @system.regenerate_identity_certificates
    render :json => @system.to_json
  end

  def update
    # only facts can be updated atm
    if params.has_key?(:facts)
      @system.facts = params[:facts]
      @system.save!
    end
    render :json => @system.to_json
  end

  def index
    render :json => @organization.systems.to_json
  end

  def show
    render :json => @system.to_json
  end

  def destroy
     @system.destroy
    render :text => _("Deleted system '#{params[:id]}'"), :status => 204
  end

  def find_organization
    return if params.has_key?(:organization_id)

    @organization = Organization.first(:conditions => {:cp_key => params[:organization_id]})
    render :text => _("Couldn't find organization '#{params[:organization_id]}'"), :status => 404 and return if @organization.nil?
    @organization
  end

  def find_environment
    return if params.has_key?(:environment_id)

    @environment = KPEnvironment.first(params[:environment_id])
    render :text => _("Couldn't find environment '#{params[:environment_id]}'"), :status => 404 and return if @environment.nil?
    @environment
  end

  def verify_presence_of_organization_or_environment
    return if @organization or @environment
    render :text => _("Either organization id or environment id needs to be specified"), :status => 404 and return if @organization.nil?
  end

  def find_system
    @system = System.first(:conditions => {:uuid => params[:id]})
    render :text => _("Couldn't find system '#{params[:id]}'"), :status => 404 and return if @system.nil?
    @system
  end

end
