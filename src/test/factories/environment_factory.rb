FactoryGirl.define do
  factory :k_t_environment do

    ignore do
      stubbed_org = true
    end

    after_build do |environment|
      environment.organization = FactoryGirl.build_stubbed(:organization, :acme_corporation) if stubbed_org
    end

    trait :library do
      name          "Library"
      description   "This is the Library"
      label         "library_label"
      library       true
    end

    trait :dev do
      name          "Dev"
      description   "Dev environment."
      label         "dev_label"
      association   :priors
    end

    trait :staging do
      name          "Staging"
      description   "Staging environment."
      label         "staging_label"
      association   :priors
    end

  end
end
