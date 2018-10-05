FactoryBot.modify do
  factory :smart_proxy do
    transient do
      download_policy 'on_demand'
    end

    trait :default_smart_proxy do
      after(:build) do |proxy, _evaluator|
        proxy.features << Feature.find_or_create_by(:name => 'Pulp')
        proxy.url = "https://#{Socket.gethostname}:9090"
        proxy.puppet_path = '/etc/puppet/environments'
      end
    end

    trait :pulp_mirror do
      after(:build) do |proxy, _evaluator|
        proxy.features << Feature.find_or_create_by(:name => 'Pulp Node')
      end
    end
  end
end
