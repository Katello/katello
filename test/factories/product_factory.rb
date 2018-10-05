FactoryBot.define do
  factory :katello_product, :class => Katello::Product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:label) { |n| "product_#{n}" }
    association :provider, :factory => :katello_provider, :strategy => :build

    trait :fedora do
      name "Fedora"
      description "The open source Linux distribution."
      label "fedora_label"
    end

    trait :with_provider do
      association :provider, factory: :katello_provider
    end
  end
end
