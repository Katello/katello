FactoryGirl.define do
  factory :docker_manifest, :class => Katello::DockerManifest do
    sequence(:name) { |n| "2.#{n}" }
    digest { SecureRandom.hex }
    uuid { SecureRandom.hex }
    schema_version 2
    trait :schema1 do
      schema_version 1
    end
  end
end
