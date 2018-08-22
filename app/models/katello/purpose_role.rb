module Katello
  class PurposeRole < Katello::Model
    self.table_name = 'katello_purpose_roles'

    has_many :subscription_facet_purpose_roles, :class_name => "Katello::SubscriptionFacetPurposeRole", :dependent => :destroy, :inverse_of => :purpose_role

    has_many :subscription_facets, :through => :subscription_facet_purpose_addons, :class_name => "Katello::Host::SubscriptionFacet"
  end
end
