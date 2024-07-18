module Katello
  class SubscriptionFacetPool < Katello::Model
    # NOTE: Do not use active record call backs or dependent references on this class
    # Direct deletes are made in Pool#import_hosts (instead of destroys).
    belongs_to :subscription_facet, :inverse_of => :subscription_facet_pools, :class_name => 'Katello::Host::SubscriptionFacet'
    belongs_to :pool, :inverse_of => :subscription_facet_pools, :class_name => 'Katello::Pool'
  end
end
