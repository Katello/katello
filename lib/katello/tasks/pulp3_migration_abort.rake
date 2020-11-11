namespace :katello do
  desc "Cancels all running Pulp 2 to 3 migration tasks."
  task :pulp3_migration_abort => ["environment", "disable_dynflow"] do
    migration_tasks = ForemanTasks::Task::DynflowTask.where(:label => "Actions::Pulp3::ContentMigration").where.not(:state => ["stopped", "paused"])
    cancelled_tasks_count = 0
    migration_tasks.each do |task|
      task.execution_plan.steps.each do |_number, step|
        if step.cancellable? && step.is_a?(Dynflow::ExecutionPlan::Steps::RunStep)
          ::ForemanTasks.dynflow.world.event(task.execution_plan.id, step.id, Dynflow::Action::Cancellable::Cancel)
          cancelled_tasks_count += 1
        end
      end
    end

    puts _("\e[33mCancelled #{cancelled_tasks_count} tasks.\e[0m")
  end
end
