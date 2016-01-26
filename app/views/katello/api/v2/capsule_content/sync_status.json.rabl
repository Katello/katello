object @capsule_content

attribute :last_sync_time

child :active_sync_tasks => :active_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end
child :last_failed_sync_tasks => :last_failed_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end

child :lifecycle_environments => :lifecycle_environments do
  extends 'katello/api/v2/common/identifier'
  extends 'katello/api/v2/common/org_reference'

  attributes :library
  node :syncable do |env|
    @capsule_content.environment_syncable?(env)
  end
end
