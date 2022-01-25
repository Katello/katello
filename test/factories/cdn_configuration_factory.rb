FactoryBot.define do
  factory :katello_cdn_configuration, :class => Katello::CdnConfiguration do
    url { Katello::Resources::CDN::CdnResource.redhat_cdn_url }
    trait :upstream_server do
      type { ::Katello::CdnConfiguration::UPSTREAM_SERVER_TYPE }
    end

    trait :airgapped do
      type { ::Katello::CdnConfiguration::AIRGAPPED_TYPE }
    end

    trait :redhat_cdn do
      type { ::Katello::CdnConfiguration::CDN_TYPE }
    end
  end
end
