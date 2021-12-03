FactoryBot.define do
  factory :katello_repository, :class => Katello::Repository do
    association :root, :factory => :katello_root_repository, :strategy => :build

    sequence(:pulp_id) { |n| "pulp-#{n}" }
    sequence(:relative_path) { |n| "/ACME_Corporation/DEV/Repo#{n}" }

    transient do
      product { nil }
      product_id { nil }
      content_id { nil }
      content_type { nil }
      label { nil }
      name { nil }
      docker_upstream_name { nil }
      url { nil }
      unprotected { nil }
      download_policy { nil }
      mirroring_policy { nil }
    end

    after(:build) do |repo, evaluator|
      %w(product product_id content_id content_type label name docker_upstream_name url unprotected download_policy mirroring_policy).each do |attr|
        repo.root.send("#{attr}=", evaluator.send(attr)) if evaluator.send(attr)
      end
    end

    trait :fedora_17_el6 do
      association :root, :factory => :katello_root_repository, :trait => :fedora_17_el6_root, :strategy => :build
      pulp_id { "Fedora_17_el6" }
      relative_path { "/ACME_Corporation/Library/fedora_17_el6_label" }
    end

    trait :fedora_17_x86_64_dev do
      association :root, :fedora_17_x86_64_dev_root, :factory => :katello_root_repository, :strategy => :build
      name { "Fedora 17" }
      label { "fedora_17_dev_label" }
      pulp_id { "2" }
      content_id { "1" }
      relative_path { "/ACME_Corporation/DEV/fedora_17_el6_label" }
    end

    trait :docker do
      association :root, :docker_root, :factory => :katello_root_repository, :strategy => :build
      relative_path { "empty_organization-fedora_label-dockeruser_repo" }
    end

    trait :iso do
      association :root, :iso_root, :factory => :katello_root_repository, :strategy => :build
    end

    trait :ostree do
      association :root, :ostree_root, :factory => :katello_root_repository, :strategy => :build
    end

    trait :with_content_view do
      association :content_view_version, factory: :katello_content_view_version
    end

    trait :with_product do
      with_content_view

      product { FactoryBot.create(:katello_product, :with_provider, organization: organization) }
    end

    trait :deb do
      association :root, :deb_root, :factory => :katello_root_repository, :strategy => :build
    end

    factory :docker_repository, traits: [:docker]
  end
end
