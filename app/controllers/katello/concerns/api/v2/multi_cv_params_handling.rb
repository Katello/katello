module Katello
  module Concerns
    module Api::V2::MultiCVParamsHandling
      extend ActiveSupport::Concern
      include ::Katello::Api::V2::ErrorHandling

      def handle_errors(candlepin_names: [], ids: [])
        if candlepin_names.present?
          fail HttpErrors::UnprocessableEntity, "No content view environments found with names: #{candlepin_names.join(',')}"
        elsif ids.present?
          fail HttpErrors::UnprocessableEntity, "No content view environments found with ids: #{ids}"
        end
      rescue HttpErrors::UnprocessableEntity => error
        respond_for_exception(
          error,
          :status => :unprocessable_entity,
          :text => error.message,
          :errors => [error.message],
          :with_logging => true
        )
      end
    end
  end
end
