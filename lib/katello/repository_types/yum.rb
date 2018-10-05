Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
  service_class Katello::Pulp::Repository::Yum
end
