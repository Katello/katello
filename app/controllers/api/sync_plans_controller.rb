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

class Api::SyncPlansController < Api::ApiController

  before_filter :find_organization
  before_filter :find_plan, :only => [:update, :show, :destroy]
  before_filter :authorize
  respond_to :json

  def rules
    access_test = lambda{Provider.any_readable?(@organization)}

    {
      :index => access_test,
      :show => access_test,
      :create => access_test,
      :update => access_test,
      :destroy => access_test
    }
  end

  def index
    query_params.delete :organization_id
    render :json => @organization.sync_plans.where(query_params).to_json
  end

  def show
    render :json => @plan.to_json
  end

  def create
    sync_date = params[:sync_plan][:sync_date]
    if not sync_date.kind_of? Time
        raise _("Date format is incorrect.")
    end

    params[:sync_plan][:organization] = @organization
    render :json => SyncPlan.create!(params[:sync_plan]).to_json
  end

  def update
    sync_date = params[:sync_plan][:sync_date]
    if not sync_date.nil? and not sync_date.kind_of? Time
        raise _("Date format is incorrect.")
    end

    @plan.update_attributes!(params[:sync_plan])
    @plan.save!
    @plan.products.each{ |p| p.save! }
    render :json => @plan
  end

  def destroy
    @plan.destroy
    render :text => _("Deleted sync plan '#{params[:id]}'"), :status => 200
  end

  def find_plan
    @plan = @organization.sync_plans.where(:id => params[:id]).first
    raise HttpErrors::NotFound, _("Couldn't find sync plan '#{params[:id]}' in organization '#{params[:organization_id]}'") if @plan.nil?
    @plan
  end

end
