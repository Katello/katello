Katello::RepositoryTypeManager.register(::Katello::Repository::ANSIBLE_COLLECTION_TYPE) do
  allow_creation_by_user true
  pulp3_skip_publication true
  pulp3_service_class Katello::Pulp3::Repository::AnsibleCollection
  pulp3_api_class Katello::Pulp3::Api::AnsibleCollection
  pulp3_plugin 'ansible'

  client_module_class PulpAnsibleClient
  api_class PulpAnsibleClient::ApiClient
  configuration_class PulpAnsibleClient::Configuration
  remote_class PulpAnsibleClient::AnsibleCollectionRemote
  remotes_api_class PulpAnsibleClient::RemotesCollectionApi
  repository_versions_api_class PulpAnsibleClient::RepositoriesAnsibleVersionsApi
  repositories_api_class PulpAnsibleClient::RepositoriesAnsibleApi
  distributions_api_class PulpAnsibleClient::DistributionsAnsibleApi
  distribution_class PulpAnsibleClient::AnsibleAnsibleDistribution
  repo_sync_url_class PulpAnsibleClient::AnsibleRepositorySyncURL

  content_type Katello::AnsibleCollection, :pulp3_service_class => ::Katello::Pulp3::AnsibleCollection, :user_removable => true, generic_browser: true
  default_managed_content_type :ansible_collections
end
