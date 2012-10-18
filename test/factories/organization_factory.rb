FactoryGirl.define do
  factory :organization do

    trait :acme_corporation do
      name          "ACME_Corporation"
      description   "This is the first Organization."
      label         "acme_corporation_label"
    end

  end
end
