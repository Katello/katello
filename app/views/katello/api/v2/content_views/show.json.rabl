object @resource

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :composite, :default
attributes :environment_default_id
attributes :content_view_definition_id => :definition_id

child :environments => :environments do
  attributes :id, :name
end

child :versions => :versions do
  attributes :id, :version
  attributes :created_at => :published
  attributes :environment_ids
end
child @object.repos(@environment) => :repositories do
  attributes :id, :name
end unless @environment.nil?

extends 'api/v2/common/timestamps'
