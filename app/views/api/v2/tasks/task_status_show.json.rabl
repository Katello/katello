extends 'api/v2/common/org_reference'
extends 'api/v2/common/timestamps'

attributes :finish_time, :start_time
attributes :id, :task_owner_type, :progress, :uuid, :state, :user_id, :task_owner_id, :parameters, :task_type
attributes :pending? => :pending

@result = (@task || @object).result
@result = Util::Data::ostructize(@result)

node :result do
  @result
end
