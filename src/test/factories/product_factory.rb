FactoryGirl.define do
  factory :product do
    sequence(:name) { |n| "Product#{n}" }
    environments { [FactoryGirl.build(:library)] }

    trait :fedora do
      name          "Fedora"
      description   "The open source Linux distribution."
      label         "fedora_label"
    end

  end
end
