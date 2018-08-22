module Katello
  class PurposeUsage < Katello::Model
    self.table_name = 'katello_purpose_usages'

    has_many :subscription_facet_purpose_usages, :class_name => "Katello::SubscriptionFacetPurposeUsage", :dependent => :destroy, :inverse_of => :purpose_usage

    has_many :subscription_facets, :through => :subscription_facet_purpose_usages, :class_name => "Katello::Host::SubscriptionFacet"
  end
end
