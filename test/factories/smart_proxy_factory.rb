FactoryGirl.modify do
  factory :smart_proxy do
    transient do
      download_policy 'on_demand'
    end

    trait :default_smart_proxy do
      after(:build) do |proxy, _evaluator|
        proxy.features << Feature.find_or_create_by(:name => 'Pulp')
      end
    end
  end
end
