object @resource

attributes :id, :schema_version, :digest, :manifest_type
child :docker_manifest_platforms => :platforms do
  attributes :os, :arch
end

child :docker_tags => :tags do
  attributes :associated_meta_tag_identifier => :id
  attributes :repository_id, :name
end

child :docker_manifests => :manifests do
  attributes :id, :digest, :schema_version, :manifest_type, :layers_size
  child :docker_manifest_platforms => :platforms do
    attributes :os, :arch
  end
end
