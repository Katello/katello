FactoryGirl.define do
  factory :organization do

    trait :acme_corporation do
      name          "ACME_Corporation"
      description   "This is the first Organization."
      label         "acme_corporation_label"
    end

  factory :acme_corporation,  :traits => [:acme_corporation]

  end
end
