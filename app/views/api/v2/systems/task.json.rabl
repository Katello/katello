object @resource

attributes :id, :message, :created_at, :start_time, :state
attributes :pending? => :pending
attributes :error? => :failed

attributes :human_readable_message, :result, :message
attributes :humanize_parameters => :human_readable_parameters
attributes :result_description => :human_readable_result

attributes :affected_units

node :username do |task|
  if task.user.nil? || task.user.hidden?
    _("Unknown")
  else
    task.user.username
  end
end
