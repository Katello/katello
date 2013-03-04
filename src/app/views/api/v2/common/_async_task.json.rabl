attributes :user_id, :organization_id, :id, :uuid, :task_owner_id
attributes :task_owner_type, :task_type, :parameters
attributes :pending?, :progress, :state, :result
attributes :start_time, :finish_time

extends 'api/v2/common/timestamps'
