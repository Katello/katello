module Katello
  class Api::V2::SyncPlansController < Api::V2::ApiController
    respond_to :json

    include Katello::Concerns::FilteredAutoCompleteSearch
    before_filter :find_organization, :only => [:create, :index, :auto_complete_search]
    before_filter :find_plan, :only => [:update, :show, :destroy, :add_products, :remove_products]

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

      sync_task(::Actions::Katello::SyncPlan::Update, @sync_plan, sync_plan_params)
      respond_for_show(:resource => @sync_plan)
    end

    api :DELETE, "/organizations/:organization_id/sync_plans/:id", N_("Destroy a sync plan")
    api :DELETE, "/sync_plans/:id", N_("Destroy a sync plan")
    param :organization_id, :number, :desc => N_("Filter sync plans by organization name or label")
    param :id, :number, :desc => N_("sync plan numeric identifier")
    def destroy
      sync_task(::Actions::Katello::SyncPlan::Destroy, @sync_plan)
      respond_for_show(:resource => @sync_plan)
    end

    api :PUT, "/organizations/:organization_id/sync_plans/:id/add_products", N_("Add products to sync plan")
    param :id, String, :desc => N_("ID of the sync plan"), :required => true
    param :product_ids, Array, :desc => N_("List of product ids to add to the sync plan"), :required => true
    def add_products
      sync_task(::Actions::Katello::SyncPlan::AddProducts, @sync_plan, params[:product_ids])
      respond_for_show
    end

    api :PUT, "/organizations/:organization_id/sync_plans/:id/remove_products", N_("Remove products from sync plan")
    param :id, String, :desc => N_("ID of the sync plan"), :required => true
    param :product_ids, Array, :desc => N_("List of product ids to remove from the sync plan"), :required => true
    def remove_products
      sync_task(::Actions::Katello::SyncPlan::RemoveProducts, @sync_plan, params[:product_ids])
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
