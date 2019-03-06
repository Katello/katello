Katello::RepositoryTypeManager.register(::Katello::Repository::FILE_TYPE) do
  allow_creation_by_user true
  service_class Katello::Pulp::Repository::File
  default_removable_type Katello::FileUnit
  content_type Katello::FileUnit, :pulp2_service_class => ::Katello::Pulp::FileUnit, :removable => true, :uploadable => true
end
