object @resource

attributes :errors

node :task do
  partial('katello/api/v2/tasks/show', :object => @resource.task)
end
