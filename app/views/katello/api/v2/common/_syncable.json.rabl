attributes :sync_state, :last_sync

node :last_sync_words do |object|
  if object.try(:last_sync)
    time_ago_in_words(Time.parse(object.last_sync))
  end
end
