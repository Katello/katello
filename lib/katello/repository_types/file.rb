Katello::RepositoryTypeManager.register(::Katello::Repository::FILE_TYPE) do
  allow_creation_by_user true
  service_class Katello::Pulp::Repository::File
  pulp3_service_class Katello::Pulp3::Repository::File
  pulp3_api_class Katello::Pulp3::Api::File
  pulp3_plugin 'file'

  client_module_class PulpFileClient
  api_class PulpFileClient::ApiClient
  configuration_class PulpFileClient::Configuration
  remote_class PulpFileClient::FileFileRemote
  remotes_api_class PulpFileClient::RemotesFileApi
  repository_versions_api_class PulpFileClient::RepositoriesFileVersionsApi
  repositories_api_class PulpFileClient::RepositoriesFileApi
  distributions_api_class PulpFileClient::DistributionsFileApi
  distribution_class PulpFileClient::FileFileDistribution
  publication_class PulpFileClient::FileFilePublication
  publications_api_class PulpFileClient::PublicationsFileApi
  repo_sync_url_class PulpFileClient::RepositorySyncURL

  content_type Katello::FileUnit,
               :pulp3_service_class => ::Katello::Pulp3::FileUnit,
               :removable => true,
               :uploadable => true
  default_managed_content_type Katello::FileUnit::CONTENT_TYPE
end
