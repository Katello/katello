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

class Api::OrganizationsController < Api::ApiController

  before_filter :find_organization, :only => [:show, :update, :destroy, :products, :providers, :generate_debug_cert, :delete_debug_cert]
  respond_to :json

  def index
    render :json => (Organization.where query_params).to_json
  end

  def show
    render :json => @organization
  end

  def create
    render :json => Organization.create!(:name => params[:name], :description => params[:description], :cp_key => params[:name].tr(' ', '_')).to_json
  end

  def update
    render :json => @organization.update_attributes!(params[:organization]).to_json
  end

  def products
    render :json => @organization.products() and return
  end

  def providers
    query_params.delete(:id)

    render :json => (@organization.providers.where query_params).to_json
  end
  
  def destroy
    @organization.destroy
    render :text => _("Deleted organization '#{params[:id]}'"), :status => 200
  end

  # rhsm
  def list_owners
    # we only need key and displayName
    @user = User.find_by_username(params[:username])
    raise HttpErrors::NotFound, _("Couldn't find user '#{params[:username]}'") if @user.nil?
    orgs = @user.allowed_organizations
    # rhsm expects owner (Candlepin format)
    render :json => orgs.map {|o| {:key => o.cp_key, :displayName => o.name} }
  end

  def find_organization
    @organization = Organization.first(:conditions => {:cp_key => params[:id].tr(' ', '_')})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{params[:id]}'") if @organization.nil?
    @organization
  end

end
