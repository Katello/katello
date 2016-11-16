object @resource

attributes :id, :name, :schema_version, :digest

child :docker_tag => :tag do
  attributes :repository_id
  attributes :name
end
