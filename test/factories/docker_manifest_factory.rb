FactoryGirl.define do
  factory :docker_manifest, :class => Katello::DockerManifest do
    sequence(:name) { |n| "2.#{n}" }
    digest { SecureRandom.hex }
    uuid { SecureRandom.hex }
  end
end
