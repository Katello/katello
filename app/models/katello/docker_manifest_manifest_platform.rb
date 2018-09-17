module Katello
  class DockerManifestManifestPlatform < Katello::Model
    belongs_to :docker_manifest_platform, :inverse_of => :docker_manifest_manifest_platforms, :class_name => 'Katello::DockerManifestPlatform'
    belongs_to :docker_manifest, :inverse_of => :docker_manifest_manifest_platforms, :class_name => 'Katello::DockerManifest'
  end
end
