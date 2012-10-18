FactoryGirl.define do
  factory :product do
    association   :provider
    association   :environments

    trait :fedora do
      name          "Fedora"
      description   "The open source Linux distribution."
      label         "fedora_label"
    end

  end
end
