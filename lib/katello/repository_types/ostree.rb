Katello::RepositoryTypeManager.register(::Katello::Repository::OSTREE_TYPE) do
  service_class Katello::Pulp::Repository::Ostree
end
