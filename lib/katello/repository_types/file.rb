Katello::RepositoryTypeManager.register(::Katello::Repository::FILE_TYPE) do
  allow_creation_by_user true
  service_class Katello::Pulp::Repository::File
end
