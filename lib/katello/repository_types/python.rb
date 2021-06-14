require 'pulp_python_client'

Katello::RepositoryTypeManager.register('python') do
  allow_creation_by_user true
  pulp3_service_class Katello::Pulp3::Repository::Generic
  pulp3_api_class Katello::Pulp3::Api::Generic
  pulp3_plugin 'python'
  partial_repo_path '' #TODO: add partial repo path

  repositories_api_class PulpPythonClient::RepositoriesPythonApi
  api_class PulpPythonClient::ApiClient
  configuration_class PulpPythonClient::Configuration
  remotes_api_class PulpPythonClient::RemotesPythonApi
  distributions_api_class PulpPythonClient::DistributionsPypiApi
  repository_versions_api_class PulpPythonClient::RepositoriesPythonVersionsApi
end
