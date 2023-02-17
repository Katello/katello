FactoryBot.define do
  factory :katello_product, :class => Katello::Product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:label) { |n| "product_#{n}" }
    sequence(:cp_id) { |n| (100_000_000_000 + n).to_s }
    association :provider, :factory => :katello_provider, :strategy => :build

    trait :fedora do
      name { "Fedora" }
      description { "The open source Linux distribution." }
      label { "fedora_label" }
    end

    trait :redhat do
      sequence(:cp_id) { |n| "RH00000#{n}" }
    end

    trait :with_provider do
      association :provider, factory: :katello_provider
    end
  end
end
