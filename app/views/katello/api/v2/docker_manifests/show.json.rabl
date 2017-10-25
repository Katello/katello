object @resource

attributes :id, :name, :schema_version, :digest

child :docker_tags => :tags do
  attributes :associated_meta_tag_identifier => :id
  attributes :repository_id, :name
end
