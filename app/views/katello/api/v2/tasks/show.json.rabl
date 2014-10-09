@object ||= @task
object @object

case @object
when ::ForemanTasks::Task
  extends 'foreman_tasks/api/tasks/show'
when ::Katello::TaskStatus
  extends 'katello/api/v2/tasks/task_status_show'
else
  fail "Unsupported task type: #{@object.class.name}"
end
