module Katello
  class ComplianceReason < Katello::Model
    belongs_to :subscription_facet, :inverse_of => :compliance_reasons, :class_name => 'Katello::Host::SubscriptionFacet'
  end
end
