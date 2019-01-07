FactoryBot.define do
  factory :docker_manifest, :class => Katello::DockerManifest do
    digest { SecureRandom.hex }
    pulp_id { SecureRandom.hex }
    schema_version 2
    trait :schema1 do
      schema_version 1
    end
  end
end
