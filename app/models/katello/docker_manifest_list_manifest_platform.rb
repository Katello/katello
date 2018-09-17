module Katello
  class DockerManifestListManifestPlatform < Katello::Model
    belongs_to :docker_manifest_platform, :inverse_of => :docker_manifest_list_manifest_platforms, :class_name => 'Katello::DockerManifestPlatform'
    belongs_to :docker_manifest_list, :inverse_of => :docker_manifest_list_manifest_platforms, :class_name => 'Katello::DockerManifestList'
  end
end
