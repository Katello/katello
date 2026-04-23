object @resource

attributes :errors

node :task do
  partial 'foreman_tasks/api/tasks/show', object: @resource.task
end
