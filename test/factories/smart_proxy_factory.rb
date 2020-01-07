FactoryBot.modify do
  factory :smart_proxy do
    transient do
      download_policy { 'on_demand' }
    end

    trait :default_smart_proxy do
      after(:build) do |proxy, _evaluator|
        proxy.features << Feature.find_or_create_by(:name => 'Pulp')
        proxy.url = "https://#{Socket.gethostname}:9090"
        proxy.puppet_path = '/etc/puppet/environments'
        proxy.locations = proxy.organizations = proxy.lifecycle_environments = []
      end
    end

    trait :with_pulp3 do
      after(:create) do |proxy, _evaluator|
        plugins = Katello::RepositoryTypeManager.repository_types.values.map(&:pulp3_plugin).compact
        v3_feature = Feature.find_or_create_by(:name => ::SmartProxy::PULP3_FEATURE)
        proxy.features << v3_feature

        smart_proxy_feature = proxy.smart_proxy_features.find { |spf| spf.feature_id == v3_feature.id }
        smart_proxy_feature.capabilities = plugins
        smart_proxy_feature.settings = { pulp_url: "https://#{Socket.gethostname}",
                                         content_app_url: "http://localhost:24816" }
        smart_proxy_feature.save!
      end
    end

    trait :pulp_mirror do
      after(:build) do |proxy, _evaluator|
        proxy.locations = proxy.organizations = proxy.lifecycle_environments = []
        proxy.features << Feature.find_or_create_by(:name => 'Pulp Node')
      end
    end
  end
end
