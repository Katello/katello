object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  attributes :type, :target, :message, :messageText, :timestamp
end
