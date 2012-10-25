FactoryGirl.define do
  factory :product do

    trait :fedora do
      name          "Fedora"
      description   "The open source Linux distribution."
      label         "fedora_label"
    end

  end
end
