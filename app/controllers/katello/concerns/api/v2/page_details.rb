module Katello
  module Concerns
    module Api::V2::PageDetails
      extend ActiveSupport::Concern

      def page_details_class
        HostCountsDetails
      end

      def with_page_details(collection)
        records = collection[:results]
        preloads = page_details_class.preloads
        records = records.preload(*preloads) if preloads.any?
        collection[:results] = page_details_class.wrap(
          resource_class, records, :organization_id => params[:organization_id]
        )
        collection
      end
    end
  end
end
