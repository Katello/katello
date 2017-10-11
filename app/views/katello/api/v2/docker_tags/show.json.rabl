object @resource

extends 'katello/api/v2/docker_tags/base'

child :docker_manifest => :manifest do
  attributes :uuid => :id
  attributes :schema_version, :digest, :manifest_type
end

child :related_tags => :related_tags do
  attributes :id, :name
end
