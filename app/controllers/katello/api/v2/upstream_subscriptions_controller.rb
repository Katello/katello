module Katello
  class Api::V2::UpstreamSubscriptionsController < Api::V2::ApiController
    before_action :check_disconnected

    resource_description do
      description "Red Hat subscriptions management platform."
      api_version 'v2'
    end

    def_param_group :cp_search do
      param :page, :number, :desc => N_("Page number, starting at 1")
      param :per_page, :number, :desc => N_("Number of results per page to return.")
      param :order, String, :desc => N_("The order to sort the results in. ['asc', 'desc'] Defaults to 'desc'.")
      param :sort_by, String, :desc => N_("The field to sort the data by. Defaults to the created date.")
    end

    api :GET, "/organizations/:organization_id/upstream_subscriptions",
      N_("List available subscriptions from Red Hat Subscription Management")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    param_group :cp_search
    param :pool_ids, Array, desc: N_("Return only the upstream pools which map to the given Katello pool IDs")
    param :quantities_only, :bool, desc: N_("Only returns id and quantity fields")
    param :attachable, :bool, desc: N_("Return only subscriptions which can be attached to the upstream allocation")
    def index
      index_params = upstream_pool_params
      pools = UpstreamPool.fetch_pools(index_params)
      page = index_params[:page] || 1

      collection = scoped_search_results(
        pools[:pools], pools[:subtotal], pools[:total], page, index_params[:per_page], nil)
      respond(collection: collection)
    end

    api :PUT, "/organizations/:organization_id/upstream_subscriptions",
      N_("Update the quantity of one or more subscriptions on an upstream allocation")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    param :pools, Array, desc: N_("Array of Pools to be updated. Only pools originating upstream are accepted."), required: true do
      param :id, String, desc: N_("Katello ID of local pool to update"), required: true
      param :quantity, Integer, desc: N_("Desired quantity of the pool"), required: true
    end
    def update
      task = async_task(::Actions::Katello::UpstreamSubscriptions::UpdateEntitlements, update_params)
      respond_for_async :resource => task
    end

    api :DELETE, "/organizations/:organization_id/upstream_subscriptions",
      N_("Remove one or more subscriptions from an upstream subscription allocation")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    param :pool_ids, Array, desc: N_("Array of local pool IDs. Only pools originating upstream are accepted."), required: true
    def destroy
      task = async_task(::Actions::Katello::UpstreamSubscriptions::RemoveEntitlements, params[:pool_ids])
      respond_for_async :resource => task
    end

    api :POST, "/organizations/:organization_id/upstream_subscriptions",
      N_("Add subscriptions consumed by a manifest from Red Hat Subscription Management")
    param :pools, Array, desc: N_("Array of pools to add"), required: true do
      param :id, String, desc: N_("Candlepin ID of pool to add"), required: true
      param :quantity, :number, desc: N_("Quantity of entitlements to bind"), required: true
    end
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    def create
      task = async_task(::Actions::Katello::UpstreamSubscriptions::BindEntitlements,
                        bind_entitlements_params)
      respond_for_async resource: task
    end

    private

    def update_params
      params.permit(pools: [:id, :quantity])[:pools].map(&:to_h)
    end

    def upstream_pool_params
      upstream_params = params.permit(:page, :per_page, :order, :sort_by, :quantities_only, :attachable, pool_ids: []).to_h

      if params[:full_result] || !upstream_params[:pool_ids].empty?
        upstream_params.delete(:per_page)
        upstream_params.delete(:page)
      elsif !params[:per_page]
        upstream_params[:per_page] = Setting[:entries_per_page]
      end

      upstream_params
    end

    def bind_entitlements_params
      params.permit(pools: [:id, :quantity])[:pools].map do |pool|
        { "pool" => pool[:id], "quantity" => pool[:quantity] } if pool
      end
    end
  end
end
