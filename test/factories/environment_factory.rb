FactoryGirl.define do
  factory :k_t_environment, :aliases => [:environment] do
    sequence(:name) { |n| "Environment#{n}" }
    sequence(:label) { |n| "environment#{n}" }

    ignore do
      stubbed_org = true
    end

    after_build do |environment, e|
      environment.organization = FactoryGirl.build_stubbed(:organization, :acme_corporation) if stubbed_org
    end

    trait :library do
      name          "Library"
      description   "This is the Library"
      label         "library_label"
      library       true
    end
    factory :library, :traits => [:library]

    trait :with_library do
      after_build do |env|
        unless env.library || env.prior
          library = FactoryGirl.create(:library)
          env.priors = [library]
          env.organization = FactoryGirl.create(:organization, :library => library)
        end
      end
    end
    factory :environment_with_library, :traits => [:with_library]

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
