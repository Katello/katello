FactoryBot.define do
  factory :docker_tag, :class => Katello::DockerTag do
    sequence(:name) { |n| "2.#{n}" }
    repository :docker_repository
    association :docker_taggable, :factory => :docker_manifest
  end
  trait :schema1 do
    after(:build) do |tag|
      tag.docker_taggable.schema_version = 1
    end
  end
  trait :latest do
    name "latest"
  end

  trait :with_uuid do
    uuid { SecureRandom.hex }
  end

  trait :with_manifest_list do
    association :docker_taggable, :factory => :docker_manifest_list
  end
end
