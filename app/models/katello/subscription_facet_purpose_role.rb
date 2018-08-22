module Katello
  class SubscriptionFacetPurposeRole < Katello::Model
    belongs_to :subscription_facet, inverse_of: :subscription_facet_purpose_role, class_name: 'Katello::Host::SubscriptionFacet'
    belongs_to :purpose_role, inverse_of: :subscription_facet_purpose_roles, class_name: 'Katello::PurposeRole'
  end
end
