module Katello
  class SubscriptionFacetPool < Katello::Model
    belongs_to :subscription_facet, :inverse_of => :subscription_facet_pools, :class_name => 'Katello::Host::SubscriptionFacet'
    belongs_to :pool, :inverse_of => :subscription_facet_pools, :class_name => 'Katello::Pool'
  end
end
