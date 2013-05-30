FactoryGirl.define do
  factory :task_status do
    association     :organization
    association     :user
    sequence(:uuid) {|n| "uuid-#{n}"}
  end
end
