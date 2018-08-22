module Katello
  class SubscriptionFacetPurposeUsage < Katello::Model
    belongs_to :subscription_facet, inverse_of: :subscription_facet_purpose_usage, class_name: 'Katello::Host::SubscriptionFacet'
    belongs_to :purpose_usage, inverse_of: :subscription_facet_purpose_usages, class_name: 'Katello::PurposeUsage'
  end
end
