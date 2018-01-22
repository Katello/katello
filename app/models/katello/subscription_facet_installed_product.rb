module Katello
  class SubscriptionFacetInstalledProduct < Katello::Model
    belongs_to :subscription_facet, :inverse_of => :subscription_facet_installed_products, :class_name => 'Katello::Host::SubscriptionFacet'
    belongs_to :installed_product, :inverse_of => :subscription_facet_installed_products, :class_name => 'Katello::InstalledProduct'
  end
end
