FactoryGirl.define do
  factory :container_resource, :class => ComputeResource do
    sequence(:name) { |n| "docker_compute_resource#{n}" }

    trait :docker do
      provider 'Docker'
      user 'dockeruser1'
      password 'dockerpassword1'
      email 'container@containerization.com'
      url 'unix:///var/run/docker.sock'
    end

    factory :docker_stuff, :class => ForemanDocker::Docker, :traits => [:docker]
  end
end
