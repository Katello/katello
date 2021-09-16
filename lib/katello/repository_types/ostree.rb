require 'pulp_ostree_client'

Katello::RepositoryTypeManager.register('ostree') do
  allow_creation_by_user true
  pulp3_service_class Katello::Pulp3::Repository::Generic
  pulp3_api_class Katello::Pulp3::Api::Generic
  pulp3_plugin 'ostree'
  partial_repo_path '' #TODO: add partial repo path

  client_module_class PulpOstreeClient
  api_class PulpOstreeClient::ApiClient
  configuration_class PulpOstreeClient::Configuration
  remote_class PulpOstreeClient::OstreeOstreeRemote
  remotes_api_class PulpOstreeClient::RemotesOstreeApi
  repositories_api_class PulpOstreeClient::RepositoriesOstreeApi
  repository_versions_api_class PulpOstreeClient::RepositoriesOstreeVersionsApi
  distributions_api_class PulpOstreeClient::DistributionsOstreeApi
  distribution_class PulpOstreeClient::OstreeOstreeDistribution
  repo_sync_url_class PulpOstreeClient::RepositorySyncURL

  url_description N_("URL of an OSTree respository.")

  model_name lambda { |pulp_unit| pulp_unit["name"] }
  model_version lambda { |pulp_unit| pulp_unit["version"] }
end
