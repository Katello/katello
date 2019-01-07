FactoryBot.define do
  factory :docker_manifest_list, :class => Katello::DockerManifestList do
    digest { SecureRandom.hex }
    pulp_id { SecureRandom.hex }
    schema_version 2

    after(:build) do |manifest_list|
      manifest_list.docker_manifests << create(:docker_manifest)
    end

    trait :schema1 do
      schema_version 1
    end
  end
end
