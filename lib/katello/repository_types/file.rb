Katello::RepositoryTypeManager.register(::Katello::Repository::FILE_TYPE) do
  allow_creation_by_user true
  service_class Katello::Pulp::Repository::File
  pulp3_service_class Katello::Pulp3::Repository::File
  pulp3_api_class Katello::Pulp3::Api::File
  pulp3_plugin 'pulp_file'

  content_type Katello::FileUnit,
               :pulp2_service_class => ::Katello::Pulp::FileUnit,
               :pulp3_service_class => ::Katello::Pulp3::FileUnit,
               :removable => true,
               :uploadable => true
  default_managed_content_type Katello::FileUnit
end
