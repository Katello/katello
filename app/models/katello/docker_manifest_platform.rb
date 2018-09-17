module Katello
  class DockerManifestPlatform < Katello::Model
    has_many :docker_manifest_manifest_platforms, :dependent => :destroy, :class_name => "Katello::DockerManifestManifestPlatform"
    has_many :docker_manifests, :through => :docker_manifest_manifest_platforms

    has_many :docker_manifest_list_manifest_platforms, :dependent => :destroy, :class_name => "Katello::DockerManifestListManifestPlatform"
    has_many :docker_manifest_lists, :through => :docker_manifest_list_manifest_platforms
  end
end
