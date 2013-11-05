attributes :uuid, :action, :user_id, :organization_id

glue @object.execution_plan do
  attributes :started_at, :ended_at, :state, :result, :progress
end
