FactoryGirl.define do
  factory :provider do
    association   :organization

    trait :fedora_hosted do
      name          "FedoraHosted"
      description   "Project and repository hosting."
      provider_type "Custom"
    end

    factory :fedora_hosted_provider, :traits => [:fedora_hosted]

  end
end
