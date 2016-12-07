object @resource

attributes :id, :name, :schema_version, :digest

child :docker_tags => :tags do
  attributes :id, :repository_id, :name
end
