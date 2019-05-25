FactoryBot.define do
  factory :registry_organization, class: "Organization" do
    type { "Organization" }
    association :library, factory: :katello_library

    trait :headquarters do
      name { "Headquarters, Ltd." }
      type { "Organization" }
      description { "This is the registry headquarters." }
      label { "headquarters" }
    end

    trait :fieldoffice do
      name { "Field Office" }
      type { "Organization" }
      description { "This is the registry field office." }
      label { "fieldoffice" }
    end
  end

  factory :registry_environment, class: Katello::KTEnvironment do
    after :build do |env|
      if !env.library && !env.prior
        env.priors = [env.organization.library]
      end
    end

    trait :hq_env_dev do
      name { "Headquarters DEV" }
      description { "Headquarters DEV environment" }
      label { "hq_env_dev" }
      association :organization, factory: [:registry_organization, :headquarters]
    end

    trait :fo_env_dev do
      name { "Field Office DEV" }
      description { "Field Office DEV environment" }
      label { "fo_env_dev" }
      association :organization, factory: [:registry_organization, :fieldoffice]
    end
  end

  factory :registry_content_view, class: Katello::ContentView do
    trait :hq_cv_single_repo do
      name { "Headquarters Single Repo" }
      label { "hq_cv_single_repo" }
      composite { false }
      association :organization, factory: [:registry_organization, :headquarters]
    end
    trait :hq_cv_multi_repo do
      name { "Headquarters Multi Repo" }
      label { "hq_cv_multi_repo" }
      composite { false }
      association :organization, factory: [:registry_organization, :headquarters]
    end

    trait :fo_cv_single_repo do
      name { "Field Office Single Repo" }
      label { "fo_cv_single_repo" }
      composite false
      association :organization, factory: [:registry_organization, :fieldoffice]
    end
    trait :fo_cv_multi_repo do
      name { "Field Office Multi Repo" }
      label { "fo_cv_multi_repo" }
      composite false
      association :organization, factory: [:registry_organization, :fieldoffice]
    end
  end

  factory :registry_content_view_version, :class => Katello::ContentViewVersion do
    sequence(:major)

    trait :hq_cvv_single_repo do
      association :content_view, factory: [:registry_content_view, :hq_cv_single_repo]
    end
    trait :hq_cvv_multi_repo do
      association :content_view, factory: [:registry_content_view, :hq_cv_multi_repo]
    end

    trait :fo_cvv_single_repo do
      association :content_view, factory: [:registry_content_view, :fo_cv_single_repo]
    end
    trait :fo_cvv_multi_repo do
      association :content_view, factory: [:registry_content_view, :fo_cv_multi_repo]
    end
  end

  factory :registry_product, class: Katello::Product do
    trait :hq_product do
      name { "Headquarters Product" }
      label { "hq_product" }
    end

    trait :fo_product do
      name { "Field Office Product" }
      label { "fo_product" }
    end
  end

  factory :registry_repository, class: Katello::Repository do
    association :root, :factory => :katello_root_repository, :strategy => :build
    sequence(:pulp_id) { |n| "pulp-#{n}" }

    transient do
      product { nil }
      content_id { nil }
      content_type { nil }
      label { nil }
      name { nil }
      docker_upstream_name { nil }
      url { nil }
    end

    after(:build) do |repo, evaluator|
      %w(product content_id content_type label name docker_upstream_name url).each do |attr|
        repo.root.send("#{attr}=", evaluator.send(attr)) if evaluator.send(attr)
      end
      repo.root.unprotected = true
      repo.root.download_policy = ""
    end

    trait :hq_repo_alpha do
      content_type { "docker" }
      name { "Alpha Image" }
      label { "alpha_image" }
      relative_path { "headquarters-hq_product-alpha_image" }
      url { "http://devel.example.com:5000/alpha" }
      docker_upstream_name { "registry/alpha" }
    end
    trait :hq_repo_beta do
      content_type { "docker" }
      name { "Beta Image" }
      label { "beta_image" }
      relative_path { "headquarters-hq_product-beta_image" }
      url { "http://devel.example.com:5000/beta" }
      docker_upstream_name { "registry/beta" }
    end

    trait :fo_repo_alpha do
      content_type { "docker" }
      name { "Alpha Image2" }
      label { "alpha_image2" }
      relative_path { "fieldoffice-fo_product-alpha_image" }
      url { "http://devel.example.com:5000/alpha" }
      docker_upstream_name { "registry/alpha" }
    end
    trait :fo_repo_beta do
      content_type { "docker" }
      name { "Beta Image2" }
      label { "beta_image2" }
      relative_path { "fieldoffice-fo_product-beta_image" }
      url { "http://devel.example.com:5000/beta" }
      docker_upstream_name { "registry/beta" }
    end
  end
end
