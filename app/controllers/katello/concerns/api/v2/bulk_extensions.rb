module Katello
  module Concerns
    module Api::V2::BulkExtensions
      extend ActiveSupport::Concern

      def find_bulk_items(bulk_params:, model_scope:, key: :id)
        if bulk_params.is_a?(String)
          bulk_params = ActiveSupport::JSON.decode(bulk_params).
                        deep_symbolize_keys
        end
        bulk_params[:included] ||= {}
        bulk_params[:excluded] ||= {}

        if (!bulk_params[:all]) &&
            bulk_params[:included][:ids].blank? &&
            bulk_params[:included][:search].blank?
          fail HttpErrors::BadRequest, _("No items have been specified.")
        end

        if bulk_params[:all] && !bulk_params[:included][:ids].blank?
          fail HttpErrors::BadRequest, _("Sending a list of included IDs is not allowed when all items are being selected.")
        end

        ::Katello::BulkItemsHelper.new(bulk_params: bulk_params,
                                       model_scope: model_scope,
                                       key: key).fetch
      end
    end
  end
end
