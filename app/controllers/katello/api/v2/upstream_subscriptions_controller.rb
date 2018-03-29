require 'katello/resources/candlepin'

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
    def index
      pools = UpstreamPool.fetch_pools(upstream_pool_params.to_h)
      collection = scoped_search_results(
        pools, pools.count, nil, params[:page], params[:per_page], nil)
      respond(collection: collection)
    end

    private

    def upstream_pool_params
      params.permit(:page, :per_page, :order, :sort_by)
    end
  end
end
