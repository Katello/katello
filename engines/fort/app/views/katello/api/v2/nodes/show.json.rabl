object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/timestamps'

attributes :environment_ids
attributes :system_id

node :name do |node|
 node.system.name
end
