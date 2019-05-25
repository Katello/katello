FactoryBot.define do
  factory :recurring_logic, :class => ForemanTasks::RecurringLogic do
    cron_line { '* * * * *' }
    after(:build) { |logic| logic.task_group = build(:recurring_logic_task_group) }
  end

  factory :recurring_logic_task_group, :class => ::ForemanTasks::TaskGroups::RecurringLogicTaskGroup
end
