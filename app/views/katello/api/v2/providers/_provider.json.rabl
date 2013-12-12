extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/readonly'
extends 'katello/api/v2/common/timestamps'
attributes :id, :name, :label, :description, :discovery_url, :discovery_task_id, :provider_type
attributes :repository_url, :task_status_id, :last_sync, :discovered_repos, :repositories
attributes :total_products, :total_repositories

