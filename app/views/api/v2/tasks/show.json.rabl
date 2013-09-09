object @task

extends 'api/v2/common/org_reference'
extends 'api/v2/common/timestamps'

attributes :finish_time, :start_time
attributes :id, :task_owner_type, :progress, :pending?, :uuid, :state, :user_id, :task_owner_id, :parameters, :task_type

@result = (@task || @object).result
@result = Util::Data::ostructize(@result)

node :result do
  @result
end
