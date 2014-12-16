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

    include Katello::Concerns::FilteredAutoCompleteSearch
    before_filter :find_organization, :only => [:create, :index, :auto_complete_search]
    before_filter :find_plan, :only => [:update, :show, :destroy, :available_products, :add_products, :remove_products]
    before_filter :load_search_service, :only => [:index, :available_products]

    def_param_group :sync_plan do
      param :name, String, :desc => N_("sync plan name"), :required => true, :action_aware => true
      param :interval, SyncPlan::TYPES, :desc => N_("how often synchronization should run"), :required => true, :action_aware => true
      param :sync_date, String, :desc => N_("start datetime of synchronization"), :required => true, :action_aware => true
      param :description, String, :desc => N_("sync plan description")
      param :enabled, :bool, :desc => N_("enables or disables synchronization"), :required => true, :action_aware => true
    end

    api :GET, "/sync_plans", N_("List sync plans")
    api :GET, "/organizations/:organization_id/sync_plans"
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label"), :required => true
    param :name, String, :desc => N_("filter by name")
    param :sync_date, String, :desc => N_("filter by sync date")
    param :interval, SyncPlan::TYPES, :desc => N_("filter by interval")
    def index
      respond_for_index(:collection => scoped_search(index_relation.uniq, :name, :desc))
    end

    def index_relation
      query = SyncPlan.readable.where(:organization_id => @organization.id)
      query = query.where(:name => params[:name]) if params[:name]
      query = query.where(:sync_date => params[:sync_date]) if params[:sync_date]
      query = query.where(:interval => params[:interval]) if params[:interval]
      query
    end

    api :GET, "/organizations/:organization_id/sync_plans/:id", N_("Show a sync plan")
    api :GET, "/sync_plans/:id", N_("Show a sync plan")
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label")
    param :id, :number, :desc => N_("sync plan numeric identifier"), :required => true
    def show
      respond_for_show(:resource => @sync_plan)
    end

    api :POST, "/organizations/:organization_id/sync_plans", N_("Create a sync plan")
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label"), :required => true
    param_group :sync_plan
    def create
      sync_date = sync_plan_params[:sync_date].to_time

      unless sync_date.is_a?(Time)
        fail _("Date format is incorrect.")
      end

      @sync_plan = SyncPlan.new(sync_plan_params)
      @sync_plan.organization = @organization
      @sync_plan.save!

      respond_for_show(:resource => @sync_plan)
    end

    api :PUT, "/organizations/:organization_id/sync_plans/:id", N_("Update a sync plan")
    api :PUT, "/sync_plans/:id", N_("Update a sync plan")
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label")
    param :id, :number, :desc => N_("sync plan numeric identifier"), :required => true
    param_group :sync_plan
    def update
      sync_date = sync_plan_params.try(:[], :sync_date).try(:to_time)

      if !sync_date.nil? && !sync_date.is_a?(Time)
        fail _("Date format is incorrect.")
      end

      @sync_plan.update_attributes!(sync_plan_params)
      @sync_plan.save!
      @sync_plan.products.each { |p| p.save! }

      respond_for_show(:resource => @sync_plan)
    end

    api :DELETE, "/organizations/:organization_id/sync_plans/:id", N_("Destroy a sync plan")
    api :DELETE, "/sync_plans/:id", N_("Destroy a sync plan")
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label")
    param :id, :number, :desc => N_("sync plan numeric identifier")
    def destroy
      @sync_plan.destroy
      respond_for_show(:resource => @sync_plan)
    end

    api :GET, "/organizations/:organization_id/sync_plans/:id/available_products", N_("List products that are not in this sync plan")
    param_group :search, Api::V2::ApiController
    param :name, String, :desc => N_("product name to filter by")
    def available_products
      enabled_product_ids = Product.where(:organization_id => @organization).readable.select { |p| p.enabled? }.collect(&:id)

      filters = [:terms => {:id => enabled_product_ids - @sync_plan.product_ids}]
      filters << {:term => {:name => params[:name]}} if params[:name]

      options = {
        :filters       => filters,
        :load_records? => true
      }

      products = item_search(Product, params, options)
      respond_for_index(:collection => products)
    end

    api :PUT, "/organizations/:organization_id/sync_plans/:id/add_products", N_("Add products to sync plan")
    param :id, String, :desc => N_("ID of the sync plan"), :required => true
    param :product_ids, Array, :desc => N_("List of product ids to add to the sync plan"), :required => true
    def add_products
      ids = params[:product_ids]
      @products  = Product.where(:id => ids).editable
      @sync_plan.product_ids = (@sync_plan.product_ids + @products.collect { |p| p.id }).uniq
      @sync_plan.save!
      respond_for_show
    end

    api :PUT, "/organizations/:organization_id/sync_plans/:id/remove_products", N_("Remove products from sync plan")
    param :id, String, :desc => N_("ID of the sync plan"), :required => true
    param :product_ids, Array, :desc => N_("List of product ids to remove from the sync plan"), :required => true
    def remove_products
      ids = params[:product_ids]
      @products  = Product.where(:id => ids).editable
      @sync_plan.product_ids = (@sync_plan.product_ids - @products.collect { |p| p.id }).uniq
      @sync_plan.save!
      respond_for_show
    end

    protected

    def find_plan
      @sync_plan = SyncPlan.find_by_id(params[:id])
      fail HttpErrors::NotFound, _("Couldn't find sync plan '%{plan}' in organization '%{org}'") % { :plan => params[:id], :org => params[:organization_id] } if @sync_plan.nil?
      @organization ||= @sync_plan.organization
      @sync_plan
    end

    def sync_plan_params
      params.require(:sync_plan).permit(:name, :description, :interval, :sync_date, :product_ids, :enabled)
    end
  end
end
