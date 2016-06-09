object @resource

extends 'katello/api/v2/content_view_histories/base'

child :task => :task do
  extends 'foreman_tasks/api/tasks/show'
end

extends 'katello/api/v2/common/timestamps'
