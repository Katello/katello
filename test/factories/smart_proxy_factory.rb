FactoryBot.modify do
  factory :smart_proxy do
    transient do
      download_policy { 'on_demand' }
    end

    trait :with_pulp3 do
      after(:create) do |proxy, _evaluator|
        plugins = Katello::RepositoryTypeManager.enabled_repository_types.values.map(&:pulp3_plugin).compact
        v3_feature = Feature.find_or_create_by(:name => ::SmartProxy::PULP3_FEATURE)
        proxy.features << v3_feature unless proxy.features.include?(v3_feature)

        smart_proxy_feature = proxy.smart_proxy_features.find { |spf| spf.feature_id == v3_feature.id }
        smart_proxy_feature.capabilities = plugins
        smart_proxy_feature.settings ||= {}
        smart_proxy_feature.settings[:pulp_url] = "https://#{Socket.gethostname}"
        smart_proxy_feature.settings[:content_app_url] = "http://localhost:24816"
        smart_proxy_feature.save!
      end
    end

    trait :pulp_mirror do
      after(:build) do |proxy, _evaluator|
        proxy.locations = proxy.organizations = proxy.lifecycle_environments = []

        v3_feature = Feature.find_or_create_by(:name => ::SmartProxy::PULP3_FEATURE)
        proxy.features << v3_feature unless proxy.features.include?(v3_feature)
        smart_proxy_feature = proxy.smart_proxy_features.find { |spf| spf.feature_id == v3_feature.id }
        smart_proxy_feature.settings ||= {}
        smart_proxy_feature.settings[:mirror] = true
      end
    end
  end
end
