object @node

extends 'api/v2/common/identifier'
extends 'api/v2/common/timestamps'

attributes :environment_ids
attributes :system_id

node :name do |node|
 node.system.name
end

node :hostname do |node|
 node.system.hostname
end