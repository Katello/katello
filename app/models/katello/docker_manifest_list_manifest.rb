module Katello
  class DockerManifestListManifest < Katello::Model
    belongs_to :docker_manifest, :inverse_of => :docker_manifest_list_manifests, :class_name => 'Katello::DockerManifest'
    belongs_to :docker_manifest_list, :inverse_of => :docker_manifest_list_manifests, :class_name => 'Katello::DockerManifestList'
  end
end
