Katello::RepositoryTypeManager.register(::Katello::Repository::DEB_TYPE) do
  pulp3_service_class Katello::Pulp3::Repository::Apt
  pulp3_api_class Katello::Pulp3::Api::Apt
  pulp3_plugin 'deb'
  prevent_unneeded_metadata_publish

  client_module_class PulpDebClient
  api_class PulpDebClient::ApiClient
  configuration_class PulpDebClient::Configuration
  remote_class PulpDebClient::DebAptRemote
  remotes_api_class PulpDebClient::RemotesAptApi
  repository_versions_api_class PulpDebClient::RepositoriesAptVersionsApi
  repositories_api_class PulpDebClient::RepositoriesAptApi
  distributions_api_class PulpDebClient::DistributionsAptApi
  distribution_class PulpDebClient::DebAptDistribution
  publication_class PulpDebClient::DebAptPublication
  publications_api_class PulpDebClient::PublicationsAptApi
  repo_sync_url_class PulpDebClient::AptRepositorySyncURL

  default_managed_content_type Katello::Deb::CONTENT_TYPE
  content_type Katello::Deb,
    :pulp3_service_class => ::Katello::Pulp3::Deb,
    :removable => true,
    :uploadable => true
end
