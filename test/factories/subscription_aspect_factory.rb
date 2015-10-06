FactoryGirl.define do
  factory :katello_subscription_aspects, :aliases => [:subscription_aspect], :class => ::Katello::Host::SubscriptionAspect do
    sequence(:uuid) { |n| "uuid-#{n}" }
  end
end
