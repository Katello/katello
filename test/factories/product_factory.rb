FactoryGirl.define do
  factory :katello_product, :class => Katello::Product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:label) { |n| "product_#{n}" }

    trait :fedora do
      name "Fedora"
      description "The open source Linux distribution."
      label "fedora_label"
    end
  end
end
