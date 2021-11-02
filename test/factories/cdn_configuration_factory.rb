FactoryBot.define do
  factory :katello_cdn_configuration, :class => Katello::CdnConfiguration do
    url { Katello::Resources::CDN::CdnResource.redhat_cdn_url }
  end
end
