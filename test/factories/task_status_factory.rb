FactoryGirl.define do
  factory :katello_task_status, :class => Katello::TaskStatus do
    association :organization, :factory => :katello_organization
    association :user, :factory => :katello_user
    sequence(:uuid) { |n| "uuid-#{n}" }
  end
end
