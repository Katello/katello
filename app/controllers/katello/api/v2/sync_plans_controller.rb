#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class Api::V2::SyncPlansController < Api::V2::ApiController
  respond_to :json

  before_filter :find_organization, :only => [:create, :index]
  before_filter :find_plan, :only => [:update, :show, :destroy, :available_products, :add_products, :remove_products]
  before_filter :load_search_service, :only => [:index, :available_products]
  before_filter :authorize

  def_param_group :sync_plan do
    param :name, String, :desc => "sync plan name", :required => true, :action_aware => true
    param :interval, SyncPlan::TYPES, :desc => "how often synchronization should run", :required => true, :action_aware => true
    param :sync_date, String, :desc => "start datetime of synchronization", :required => true, :action_aware => true
    param :description, String, :desc => "sync plan description"
  end

  def rules
    access_test = lambda { Provider.any_readable?(@organization) }
    {
        :index   => access_test,
        :show    => access_test,
        :create  => access_test,
        :update  => access_test,
        :destroy => access_test,
        :available_products => access_test,
        :add_products => access_test,
        :remove_products => access_test
    }
  end

  api :GET, "/organizations/:organization_id/sync_plans", "List sync plans"
  param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
  param :name, String, :desc => "filter by name"
  param :sync_date, String, :desc => "filter by sync date"
  param :interval, SyncPlan::TYPES, :desc => "filter by interval"
  def index
    filters = []

    if params[:sync_date]
      filters << {:terms => {:sync_date => [params[:sync_date]] }}
    elsif params[:interval]
      filters << {:terms => {:interval => [params[:interval]] }}
    end

    options = {
        :filters => filters,
        :load_records? => true
    }

    respond_for_index(:collection => item_search(SyncPlan, params, options))
  end

  api :GET, "/organizations/:organization_id/sync_plans/:id", "Show a sync plan"
  param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
  param :id, :number, :desc => "product numeric identifier", :required => true
  def show
    respond_for_show(:resource => @sync_plan)
  end

  api :POST, "/organizations/:organization_id/sync_plans", "Create a sync plan"
  param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
  param_group :sync_plan
  def create
    sync_date = sync_plan_params[:sync_date].to_time

    if !sync_date.kind_of?(Time)
      fail _("Date format is incorrect.")
    end

    @sync_plan = SyncPlan.new(sync_plan_params)
    @sync_plan.organization = @organization
    @sync_plan.save!

    respond_for_show(:resource => @sync_plan)
  end

  api :PUT, "/organizations/:organization_id/sync_plans/:id", "Update a sync plan"
  param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
  param :id, :number, :desc => "sync plan numeric identifier", :required => true
  param_group :sync_plan
  def update
    sync_date = sync_plan_params.try(:[], :sync_date).try(:to_time)

    if !sync_date.nil? && !sync_date.kind_of?(Time)
      fail _("Date format is incorrect.")
    end

    @sync_plan.update_attributes!(sync_plan_params)
    @sync_plan.save!
    @sync_plan.products.each { |p| p.save! }

    respond_for_show(:resource => @sync_plan)
  end

  api :DELETE, "/organizations/:organization_id/sync_plans/:id", "Destroy a sync plan"
  param :organization_id, :identifier, :desc => "Filter products by organization name or label", :required => true
  param :id, :number, :desc => "sync plan numeric identifier"
  def destroy
    @sync_plan.destroy
    respond_for_show(:resource => @sync_plan)
  end

  api :GET, "/organizations/:organization_id/sync_plans/:id/available_products", "List products that are not in this sync plan"
  param_group :search, Api::V2::ApiController
  param :name, String, :desc => "product name to filter by"
  def available_products
    filters = [:terms => {:id => Product.all_readable(@sync_plan.organization).pluck(:id) - @sync_plan.product_ids}]
    filters << {:term => {:name => params[:name].downcase}} if params[:name]

    options = {
        :filters       => filters,
        :load_records? => true
    }

    products = item_search(Product, params, options)
    respond_for_index(:collection => products)
  end

  api :PUT, "/organizations/:organization_id/sync_plans/:id/products", "Add products to sync plan"
  param :id, String, :desc => "ID of the sync plan", :required => true
  param :product_ids, Array, :desc => "List of product ids to add to the sync plan", :required => true
  def add_products
    ids = params[:product_ids]
    @products  = Product.readable(@organization).where(:id => ids)
    @sync_plan.product_ids = (@sync_plan.product_ids + @products.collect { |p| p.id }).uniq
    @sync_plan.save!
    respond_for_show
  end

  api :PUT, "/organizations/:organization_id/sync_plans/:id/products", "Remove products from sync plan"
  param :id, String, :desc => "ID of the sync plan", :required => true
  param :product_ids, Array, :desc => "List of product ids to remove from the sync plan", :required => true
  def remove_products
    ids = params[:product_ids]
    @products  = Product.readable(@organization).where(:id => ids)
    @sync_plan.product_ids = (@sync_plan.product_ids - @products.collect { |p| p.id }).uniq
    @sync_plan.save!
    respond_for_show
  end

  protected

  def find_plan
    @sync_plan = SyncPlan.find(params[:id])
    fail HttpErrors::NotFound, _("Couldn't find sync plan '%{plan}' in organization '%{org}'") % { :plan => params[:id], :org => params[:organization_id] } if @sync_plan.nil?
    @organization ||= @sync_plan.organization
    @sync_plan
  end

  def sync_plan_params
    params.require(:sync_plan).permit(:name, :description, :interval, :sync_date, :product_ids)
  end
end
end
