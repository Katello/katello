FactoryGirl.define do
  factory :katello_sync_plan, :class => Katello::SyncPlan do
    sequence(:name) { |n| "Sync Plan #{n}" }
    association :products, :factory => :katello_products
  end
end
