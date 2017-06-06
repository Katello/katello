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

class Api::SyncPlansController < Api::ApiController

  resource_description do
    description <<-DOC
      Synchronization plans are used to configure the scheduled
      synchronization of the repository with the upstream.
    DOC

    param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  end

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

  def param_rules
    {
      :create => {:sync_plan  => [:name, :description, :sync_date, :interval]},
      :update =>  {:sync_plan  => [:name, :description, :sync_date, :interval]}
    }
  end

  def_param_group :sync_plan do
    param :sync_plan, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "sync plan name", :required => true
      param :interval, ['none', 'hourly', 'daily', 'weekly'], :desc => "how often synchronization should run"
      param :sync_date, String, :desc => "start datetime of synchronization"
      param :description, String, :desc => "sync plan description"
    end
  end

  api :GET, "/organizations/:organization_id/sync_plans", "List sync plans"
  param :name, String, :desc => "filter by name"
  param :sync_date, String, :desc => "filter by sync date"
  param :interval, ['none', 'hourly', 'daily', 'weekly'], :desc => "filter by interval"
  def index
    query_params.delete :organization_id
    render :json => @organization.sync_plans.where(query_params).to_json
  end

  api :GET, "/organizations/:organization_id/sync_plans/:id", "Show a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier", :required => true
  def show
    render :json => @plan.to_json
  end


  api :POST, "/organizations/:organization_id/sync_plans", "Create a sync plan"
  param_group :sync_plan
  def create
    sync_date = params[:sync_plan][:sync_date].to_time

    if not sync_date.kind_of? Time
      raise _("Date format is incorrect.")
    end

    params[:sync_plan][:organization] = @organization
    render :json => SyncPlan.create!(params[:sync_plan]).to_json
  end

  api :PUT, "/organizations/:organization_id/sync_plans/:id", "Update a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier", :required => true
  param_group :sync_plan
  def update
    sync_date = params[:sync_plan][:sync_date].to_time

    if not sync_date.nil? and not sync_date.kind_of? Time
        raise _("Date format is incorrect.")
    end

    @plan.update_attributes!(params[:sync_plan])
    @plan.save!
    @plan.products.each{ |p| p.save! }
    render :json => @plan
  end

  api :DELETE, "/organizations/:organization_id/sync_plans/:id", "Destroy a sync plan"
  param :id, :number, :desc => "sync plan numeric identifier"
  def destroy
    @plan.destroy
    render :text => _("Deleted sync plan '%s'") % params[:id], :status => 200
  end

  def find_plan
    @plan = @organization.sync_plans.where(:id => params[:id]).first
    raise HttpErrors::NotFound, _("Couldn't find sync plan '%{plan}' in organization '%{org}'") % {:plan => params[:id], :org => params[:organization_id]} if @plan.nil?
    @plan
  end

end
