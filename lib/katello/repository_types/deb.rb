Katello::RepositoryTypeManager.register(::Katello::Repository::DEB_TYPE) do
  service_class Katello::Pulp::Repository::Deb
end
