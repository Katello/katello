Katello::RepositoryTypeManager.register(::Katello::Repository::DOCKER_TYPE) do
  service_class Katello::Pulp::Repository::Docker
  default_managed_content_type Katello::DockerManifest
  pulp3_service_class Katello::Pulp3::Repository::Docker
  pulp3_api_class Katello::Pulp3::Api::Docker
  pulp3_skip_publication true
  pulp3_plugin 'container'

  set_unique_content_per_repo

  content_type Katello::DockerManifest,
               :priority => 1,
               :pulp2_service_class => ::Katello::Pulp::DockerManifest,
               :pulp3_service_class => ::Katello::Pulp3::DockerManifest,
               :removable => true,
               :uploadable => true
  content_type Katello::DockerManifestList,
               :priority => 2,
               :pulp2_service_class => ::Katello::Pulp::DockerManifestList,
               :pulp3_service_class => ::Katello::Pulp3::DockerManifestList
  content_type Katello::DockerTag,
               :priority => 3,
               :pulp2_service_class => ::Katello::Pulp::DockerTag,
               :pulp3_service_class => ::Katello::Pulp3::DockerTag
  content_type Katello::DockerBlob,
               :priority => 4,
               :pulp2_service_class => ::Katello::Pulp::DockerBlob,
               :pulp3_service_class => ::Katello::Pulp3::DockerBlob,
               :index => false
end
