module Katello
  class SubscriptionFacetPurposeAddon < Katello::Model
    belongs_to :subscription_facet, inverse_of: :subscription_facet_purpose_addons, class_name: 'Katello::Host::SubscriptionFacet'
    belongs_to :purpose_addon, inverse_of: :subscription_facet_purpose_addons, class_name: 'Katello::PurposeAddon'
  end
end
