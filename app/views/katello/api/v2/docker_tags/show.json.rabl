object @resource

extends 'katello/api/v2/docker_tags/base'

child :docker_manifest => :manifest do
  attributes :uuid => :id
  attributes :name, :schema_version, :digest
end

child :related_tags => :related_tags do
  attributes :id, :name
end
