FactoryGirl.define do
  factory :task_status, :class => Katello::TaskStatus do
    association :organization
    association :user
    sequence(:uuid) { |n| "uuid-#{n}" }
  end
end
