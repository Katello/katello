FactoryGirl.define do
  factory :system do
    sequence(:name) {|n| "System#{n}"}
    cp_type "system"
    facts { {"Test" => ""} }

    ignore do
      stubbed = true
    end

    trait :alabama do
      name     "Alabama"
    end

  end
end
