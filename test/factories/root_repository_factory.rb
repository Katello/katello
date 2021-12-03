FactoryBot.define do
  factory :katello_root_repository, :class => Katello::RootRepository do
    sequence(:name) { |n| "Repo #{n}" }
    sequence(:label) { |n| "repo_#{n}" }
    sequence(:content_id)
    url { "http://localhost/foo" }
    download_policy { "on_demand" }
    mirroring_policy { "mirror_content_only" }

    association :product, :factory => :katello_product, :strategy => :build
    http_proxy_policy { Katello::RootRepository::NO_DEFAULT_HTTP_PROXY }

    trait :fedora_17_el6_root do
      name { "Fedora 17 el6" }
      label { "fedora_17_el6_label" }
      content_id { "450" }
    end

    trait :fedora_17_x86_64_dev_root do
      name { "Fedora 17" }
      label { "fedora_17_dev_label" }
      content_id { "1" }
    end

    trait :docker_root do
      content_type { "docker" }
      docker_upstream_name { "dockeruser/repo" }
      download_policy { "" }
      unprotected { true }
    end

    trait :iso_root do
      content_type { "file" }
      download_policy { "" }
    end

    trait :ostree_root do
      content_type { "ostree" }
      download_policy { "" }
    end

    trait :deb_root do
      content_type { "deb" }
      download_policy { "" }
      deb_releases { "5 6" }
      deb_components { "best" }
      deb_architectures { "x86_64" }
    end

    factory :docker_root_repository, traits: [:docker_root]
  end
end
