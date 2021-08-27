Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
  service_class Katello::Pulp::Repository::Yum
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
    :pulp2_service_class => ::Katello::Pulp::Rpm,
    :pulp3_service_class => ::Katello::Pulp3::Rpm,
    :removable => true,
    :uploadable => true
  content_type Katello::ModuleStream,
    :priority => 2,
    :pulp2_service_class => ::Katello::Pulp::ModuleStream,
    :pulp3_service_class => ::Katello::Pulp3::ModuleStream
  content_type Katello::Erratum, :priority => 3,
    :pulp2_service_class => ::Katello::Pulp::Erratum,
    :pulp3_service_class => ::Katello::Pulp3::Erratum
  content_type Katello::PackageGroup,
    :pulp2_service_class => ::Katello::Pulp::PackageGroup,
    :pulp3_service_class => ::Katello::Pulp3::PackageGroup
  content_type Katello::YumMetadataFile,
    :pulp2_service_class => ::Katello::Pulp::YumMetadataFile,
    :pulp3_service_class => ::Katello::Pulp3::YumMetadataFile,
    :index_on_pulp3 => false
  content_type Katello::Srpm,
    :pulp2_service_class => ::Katello::Pulp::Srpm,
    :pulp3_service_class => ::Katello::Pulp3::Srpm,
    :removable => true, :uploadable => true
  content_type Katello::Distribution, :priority => 4,
    :pulp2_service_class => ::Katello::Pulp::Distribution,
    :pulp3_service_class => ::Katello::Pulp3::Distribution,
    :index => false
  content_type Katello::PackageCategory, :priority => 4, :pulp2_service_class => ::Katello::Pulp::PackageCategory, :index => false

  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
end
