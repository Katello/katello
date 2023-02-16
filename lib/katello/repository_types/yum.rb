Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
  pulp3_service_class Katello::Pulp3::Repository::Yum
  pulp3_api_class Katello::Pulp3::Api::Yum
  pulp3_plugin 'rpm'
  prevent_unneeded_metadata_publish

  client_module_class PulpRpmClient
  api_class PulpRpmClient::ApiClient
  remote_class PulpRpmClient::RpmRpmRemote
  remotes_api_class PulpRpmClient::RemotesRpmApi
  repository_versions_api_class PulpRpmClient::RepositoriesRpmVersionsApi
  repositories_api_class PulpRpmClient::RepositoriesRpmApi
  configuration_class PulpRpmClient::Configuration
  distributions_api_class PulpRpmClient::DistributionsRpmApi
  distribution_class PulpRpmClient::RpmRpmDistribution
  publication_class PulpRpmClient::RpmRpmPublication
  publications_api_class PulpRpmClient::PublicationsRpmApi
  repo_sync_url_class PulpRpmClient::RpmRepositorySyncURL

  default_managed_content_type Katello::Rpm::CONTENT_TYPE
  content_type Katello::Rpm,
    :priority => 1,
    :pulp3_service_class => ::Katello::Pulp3::Rpm,
    :primary_content => true,
    :removable => true,
    :uploadable => true
  content_type Katello::ModuleStream,
    :priority => 2,
    :pulp3_service_class => ::Katello::Pulp3::ModuleStream
  content_type Katello::Erratum, :priority => 3,
    :pulp3_service_class => ::Katello::Pulp3::Erratum,
    :primary_content => true, :mutable => true
  content_type Katello::PackageGroup,
    :pulp3_service_class => ::Katello::Pulp3::PackageGroup
  content_type Katello::Srpm,
    :pulp3_service_class => ::Katello::Pulp3::Srpm,
    :removable => true, :uploadable => true
  content_type Katello::Distribution, :priority => 4,
    :pulp3_service_class => ::Katello::Pulp3::Distribution,
    :index => false
  content_type Katello::PackageCategory, :priority => 4, :index => false

  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
end
