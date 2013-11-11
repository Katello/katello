@object ||= @task
object @object

case @object
when DynflowTask
  extends 'api/v2/tasks/dynflow_task_show'
when TaskStatus
  extends 'api/v2/tasks/task_status_show'
else
  raise "Unsupported task type: #{@object.class.name}"
end

