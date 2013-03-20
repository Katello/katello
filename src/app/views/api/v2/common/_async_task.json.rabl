attributes :user_id, :organization_id, :id, :uuid, :task_owner_id
attributes :task_owner_type, :task_type, :parameters
attributes :pending?, :state
attributes :start_time, :finish_time
attributes :result

child :progress => :progress do
  attributes :total_count, :total_size, :size_left, :items_left, :step
  attributes :error_details
end

extends 'api/v2/common/timestamps'
