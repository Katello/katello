object @task if @task

attributes :uuid, :action, :user_id, :organization_id, :pending
attributes :inputs, :outputs

glue (@task || @object).execution_plan do
  attributes :started_at, :ended_at, :state, :result, :progress
end
