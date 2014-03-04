object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :composite
attributes :repository_ids
attributes :component_ids

node :last_published do |content_view|
  if !content_view.versions.empty?
    content_view.versions.last.created_at
  end
end

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
end

child :repositories => :repositories do
  attributes :id, :name, :label
end

child :components => :components do
  attributes :id, :name
  attributes :version, :content_view_id
  attributes :created_at => :published
end

extends 'katello/api/v2/common/timestamps'
