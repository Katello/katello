FactoryGirl.define do
  factory :filter_rule do
    association :filter
    trait :package_filter do
      content_type "rpm"
      parameters ({:units =>[{:name =>["g*"]}]}).with_indifferent_access
    end

    trait :inclusive do
      inclusion true
    end
    trait :exclusive do
      inclusion false
    end

    factory :package_filter_rule,  :traits => [:package_filter, :inclusive]
    factory :package_filter_rule_exclusive,  :traits => [:package_filter, :exclusive]
  end
end