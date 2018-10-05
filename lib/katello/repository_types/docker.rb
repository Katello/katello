Katello::RepositoryTypeManager.register(::Katello::Repository::DOCKER_TYPE) do
  service_class Katello::Pulp::Repository::Docker
end
