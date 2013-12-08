FactoryGirl.define do
  factory :system, :class => Katello::System do

    ignore do
      stubbed = true
    end

    trait :alabama do
      name "Alabama"
    end

  end
end
