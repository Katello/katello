module Katello
  module Concerns
    module Api::V2::MultiCVParamsHandling
      extend ActiveSupport::Concern
      include ::Katello::Api::V2::ErrorHandling

      def handle_errors(labels: [], ids: [])
        if labels.present?
          fail HttpErrors::UnprocessableEntity, "No content view environments found with names: #{labels.join(',')}"
        elsif ids.present?
          fail HttpErrors::UnprocessableEntity, "No content view environments found with ids: #{ids}"
        end
      rescue HttpErrors::UnprocessableEntity => e
        respond_for_exception(
          e,
          :status => :unprocessable_entity,
          :text => e.message,
          :errors => [e.message],
          :with_logging => true
        )
      end
    end
  end
end
