extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'
attributes :id, :name, :label, :description, :discovery_url, :discovery_task_id, :provider_type
attributes :repository_url, :task_status_id, :last_sync
attributes :total_products, :total_repositories
attributes :rules_source, :rules_version

child :repositories => :repositories do
  attributes :id, :name
end

child :products => :products do
  attributes :id, :name
end
