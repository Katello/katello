FactoryBot.define do
  factory :foreman_task, :class => ForemanTasks::Task do
    sequence(:label) { |n| "task#{n}" }
    sequence(:id) { |n| 'b8317062-c664-4792-9d9a-8167b23c%04d' % n }
    type { 'ForemanTasks::Task' }
    state { 'stopped' }
    result { 'success' }
    sequence(:started_at) { |n| "2016-#{(n / 30) + 1}-#{(n % 30) + 1} 11:15:00" }
    after(:build) do |task|
      task.ended_at = task.started_at.change(:sec => 32) if task.started_at
    end

    trait :running do
      state { 'running' }
      result { 'pending' }
      ended_at { nil }
    end

    trait :failed do
      state { 'paused' }
      result { 'error' }
      ended_at { nil }
    end

    trait :scheduled do
      state { 'scheduled' }
      result { 'pending' }
      started_at { nil }
      ended_at { nil }
    end
  end

  factory :dynflow_task, :parent => :foreman_task, :class => ForemanTasks::Task::DynflowTask do
    type { 'ForemanTasks::Task::DynflowTask' }
  end
end
