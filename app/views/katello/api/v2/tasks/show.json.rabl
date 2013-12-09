@object ||= @task
object @object

case @object
when ::ForemanTasks::Task
  extends 'katello/api/v2/tasks/dynflow_task_show'
when ::Katello::TaskStatus
  extends 'katello/api/v2/tasks/task_status_show'
else
  raise "Unsupported task type: #{@object.class.name}"
end

