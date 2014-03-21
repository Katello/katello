object @resource

extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :finish_time, :start_time
attributes :id, :task_owner_type, :progress, :uuid, :state, :user_id, :task_owner_id, :parameters, :task_type
attributes :pending? => :pending
attributes :system
attributes :human_readable_message

@result = (@task || @object).result

node :result do
  @result
end
