object @organization

attributes :id, :name, :task_id, :label, :description, :service_levels, :service_level, :system_info_keys, :distributor_info_keys, :default_info, :owner_auto_attach_all_systems_task_id
extends 'api/v2/common/timestamps'


node :discovery_task_id do |org|
  org.repo_discovery_task.try(:id)
end
