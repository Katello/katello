module Katello
  class PurposeAddon < Katello::Model
    self.table_name = 'katello_purpose_addons'

    has_many :subscription_facet_purpose_addons, :class_name => "Katello::SubscriptionFacetPurposeAddon", :dependent => :destroy, :inverse_of => :purpose_addon
    has_many :subscription_facets, :through => :subscription_facet_purpose_addons, :class_name => "Katello::Host::SubscriptionFacet"

    has_many :activation_key_purpose_addons, :class_name => "Katello::ActivationKeyPurposeAddon", :dependent => :destroy, :inverse_of => :purpose_addon
    has_many :activation_keys, :through => :activation_key_purpose_addons, :class_name => "Katello::ActivationKey"
  end
end
