module Katello
  class SubscriptionFacetActivationKey < Katello::Model
    belongs_to :subscription_facet, :inverse_of => :subscription_facet_activation_keys, :class_name => 'Katello::Host::SubscriptionFacet'
    belongs_to :activation_key, :inverse_of => :subscription_facet_activation_keys, :class_name => 'Katello::ActivationKey'
  end
end
