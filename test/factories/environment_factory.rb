FactoryGirl.define do
  factory :k_t_environment, :aliases => [:environment] do
    sequence(:name) { |n| "Environment#{n}" }
    sequence(:label) { |n| "environment#{n}" }
    association :organization

    trait :stubbed_org do
      association :organization, :strategy => :build_stubbed
    end

    trait :library do
      name "Library"
      description "This is the Library"
      sequence(:label) { |n| "library_label_#{n}" }
      library true

      after_build do |lib|
        lib.organization.library = lib
      end
    end
    factory :library, :traits => [:library]

    trait :with_library do
      after_build do |env|
        unless env.library || env.prior
          library = FactoryGirl.build(:library, :organization => env.organization)
          env.priors = [library]
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
