module Katello
  class BulkItemsHelper
    attr_reader :bulk_params, :model_scope, :key

    def initialize(bulk_params:, model_scope:, key: :id)
      @bulk_params = bulk_params

      if @bulk_params.is_a?(String)
        @bulk_params = ActiveSupport::JSON.decode(@bulk_params).
                      deep_symbolize_keys
      end

      @model_scope = model_scope
      @key = key
    end

    def fetch
      params = bulk_params
      params[:included] ||= {}
      params[:excluded] ||= {}

      items = model_scope
      if params[:included][:ids]
        items = model_scope.where(key => params[:included][:ids])
      elsif params[:included][:search]
        items = model_scope.search_for(params[:included][:search])
      end
      if params[:excluded][:ids]
        items = items.where.not(key => params[:excluded][:ids])
      end

      items
    end
  end
end
