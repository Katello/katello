object @notice

attributes :id, :created_at, :level, :text, :details

node :organization do |notice|
  {
    :name => notice.organization
  }
end

extends 'api/v2/common/timestamps'
extends 'api/v2/common/readonly'
