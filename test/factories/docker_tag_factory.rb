FactoryBot.define do
  factory :docker_tag, :class => Katello::DockerTag do
    sequence(:name) { |n| "2.#{n}" }
    pulp_id { SecureRandom.hex }

    association :docker_taggable, :factory => :docker_manifest

    trait :schema1 do
      association :docker_taggable, :factory => [:docker_manifest, :schema1]
    end
    trait :latest do
      name { "latest" }
    end

    trait :with_uuid do
      pulp_id { SecureRandom.hex }
    end

    trait :with_manifest_list do
      association :docker_taggable, :factory => :docker_manifest_list
    end
  end
end
