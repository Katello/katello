FactoryGirl.define do
  factory :docker_image, :class => Katello::DockerImage do
    image_id { SecureRandom.hex }
    uuid { SecureRandom.hex }
  end
end
