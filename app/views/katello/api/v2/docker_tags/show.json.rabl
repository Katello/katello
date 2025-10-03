object @resource

extends 'katello/api/v2/docker_tags/base'

child :docker_manifest => :manifest do
  attributes :uuid => :id
  attributes :schema_version, :digest, :manifest_type
  node :manifests, :if => lambda { |m| m.manifest_type == 'list' } do |manifest|
    manifest.docker_manifests.map do |child_manifest|
      {
        :id => child_manifest.id,
        :digest => child_manifest.digest,
        :schema_version => child_manifest.schema_version,
        :manifest_type => child_manifest.manifest_type,
      }
    end
  end
end

child :related_tags => :related_tags do
  attributes :id, :name
end
