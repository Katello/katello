FactoryGirl.define do
  factory :container do
    sequence(:name) { |n| "katello_container_#{n}" }
    association :compute_resource, :factory => :docker_stuff
    sequence(:repository_name) { |n| "katello_repo#{n}" }
    sequence(:tag) { |n| "katello_tag#{n}" }
    katello true
  end
end
