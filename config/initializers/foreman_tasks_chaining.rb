# frozen_string_literal: true

# FIXME: This monkey-patch adds execution plan chaining support to ForemanTasks.
# This should be submitted upstream to the foreman-tasks gem and removed from here
# once it's available in a released version.
#
# See: https://github.com/Dynflow/dynflow/pull/446

# Defer extension until after ForemanTasks module is loaded
Rails.application.config.to_prepare do
  module ForemanTasks
    # Chain execution plans so that a new plan waits until prerequisite plans finish before executing.
    # This is useful for coordinating dependent tasks where one task should only run after
    # other tasks have completed successfully.
    #
    # The chained plan will remain in 'scheduled' state until all prerequisite plans
    # reach 'stopped' state (regardless of success/failure).
    #
    # @param plan_uuids [String, Array<String>] UUID(s) of prerequisite execution plan(s)
    # @param action [Class] Action class to execute
    # @param args Arguments to pass to the action
    # @return [ForemanTasks::Task::DynflowTask] The chained task that will wait for prerequisites
    #
    # @example Chain a task to wait for another task
    #   task1 = ForemanTasks.async_task(SomeAction)
    #   task2 = ForemanTasks.chain(task1.external_id, AnotherAction, arg1, arg2)
    #   # task2 will only execute after task1 completes
    #
    # @example Chain a task to wait for multiple tasks
    #   task1 = ForemanTasks.async_task(Action1)
    #   task2 = ForemanTasks.async_task(Action2)
    #   task3 = ForemanTasks.chain([task1.external_id, task2.external_id], Action3)
    #   # task3 will only execute after both task1 and task2 complete
    def self.chain(plan_uuids, action, *args)
      result = dynflow.world.chain(plan_uuids, action, *args)
      # The ForemanTasks record may not exist yet for delayed plans,
      # so we need to find or create it
      ForemanTasks::Task.find_by(:external_id => result.id) ||
        ForemanTasks::Task::DynflowTask.new(:external_id => result.id).tap do |task|
          task.save!
        end
    end
  end
end
