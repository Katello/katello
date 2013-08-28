attributes :id, :message, :created_at, :start_time
attributes :pending? => :pending
attributes :error? => :failed

attributes :human_readable_message, :result
attributes :humanize_parameters => :human_readable_parameters
attributes :result_description => :human_readable_result

node :username do |task|
  if task.user.nil? || task.user.hidden?
    _("Unknown")
  else
    task.user.username
  end
end
