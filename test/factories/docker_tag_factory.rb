FactoryGirl.define do
  factory :docker_tag, :class => Katello::DockerTag do
    sequence(:name) { |n| "2.#{n}" }
    repository :docker_repository
    docker_image
  end

  trait :latest do
    name "latest"
  end
end
