FactoryGirl.define do
  factory :system_template do

    sequence(:name) { |n| "SystemTemplate#{n}" }

    association :environment

  end
end
