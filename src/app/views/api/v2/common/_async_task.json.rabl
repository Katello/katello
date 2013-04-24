progress = (@resource || @object).progress
progress = Util::Data::ostructize(progress)

attributes :user_id, :organization_id, :id, :uuid, :task_owner_id
attributes :task_owner_type, :task_type, :parameters
attributes :pending?, :state, :ovrall_status
attributes :start_time, :finish_time
attributes :result, :result_description

child progress => :progress do
  attributes :total_count, :total_size, :size_left, :items_left, :step
  attributes :error_details, :reasons, :principal_login, :exception, :traceback, :result
  attributes :state, :_href, :task_group_id, :dependency_failures
  attributes :call_request_id, :call_request_tags, :response
  attributes :progress
  attributes :task_id, :finish_time, :start_time, :schedule_id
  attributes :tags, :call_request_group_id
end

extends 'api/v2/common/timestamps'   