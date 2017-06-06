FactoryGirl.define do
  factory :system do

    ignore do
      stubbed = true
    end

    trait :alabama do
      name     "Alabama"
    end

  end
end
