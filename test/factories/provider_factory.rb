FactoryGirl.define do
  factory :provider do
    sequence(:name) { |n| "Adobe #{n}" }
    provider_type "Custom"
    association   :organization

    trait :fedora_hosted do
      name          "FedoraHosted"
      description   "Project and repository hosting."
      provider_type "Custom"
    end

    factory :fedora_hosted_provider, :traits => [:fedora_hosted]

  end
end
