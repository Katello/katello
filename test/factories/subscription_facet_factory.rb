FactoryGirl.define do
  factory :katello_subscription_facets, :aliases => [:subscription_facet], :class => ::Katello::Host::SubscriptionFacet do
    sequence(:uuid) { |n| "uuid-#{n}-#{rand(500)}" }
    facts('memory.memtotal' => "12 GB")
  end
end
