FactoryGirl.define do
  factory :docker_tag, :class => Katello::DockerTag do
    sequence(:name) { |n| "2.#{n}" }
    repository :docker_repository
    docker_manifest
  end
  trait :schema1 do
    after(:build) do |tag|
      tag.docker_manifest.schema_version = 1
    end
  end
  trait :latest do
    name "latest"
  end
end
