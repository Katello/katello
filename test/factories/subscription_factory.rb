FactoryBot.define do
  factory :katello_subscription, :class => Katello::Subscription do
    sequence(:name) { |n| "Beautiful Subscription #{n}" }
    sequence(:cp_id) { |n| "RH0000#{n}" }
  end
end
