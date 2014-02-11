object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :composite
attributes :repository_ids

child :environments => :environments do
  attributes :id, :name, :label
end

child :repositories => :repositories do
  attributes :id, :name, :label
end

child :puppet_modules => :puppet_modules do
  attributes :id, :name, :author, :uuid
  attributes :created_at
  attributes :updated_at
end

child :versions => :versions do
  attributes :id, :version
  attributes :created_at => :published
  attributes :environment_ids
  attributes :user
end

child :repositories => :repositories do
  attributes :id, :name
end

extends 'katello/api/v2/common/timestamps'
