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
  remote_class PulpPythonClient::PythonPythonRemote
  repo_sync_url_class PulpPythonClient::RepositorySyncURL
  client_module_class PulpPythonClient
  distribution_class PulpPythonClient::PythonPythonDistribution
  publication_class PulpPythonClient::PythonPythonPublication
  publications_api_class PulpPythonClient::PublicationsPypiApi

  generic_remote_option :includes, type: Array, description: "A list containing project specifiers for Python packages to include."
  generic_remote_option :excludes, type: Array, description: "A list containing project specifiers for Python packages to exclude."
  generic_remote_option :package_types, type: Array, description: "A list of package types to sync for Python content. Leave blank to get every package type."

  model_name lambda { |pulp_unit| pulp_unit["name"] }
  model_version lambda { |pulp_unit| pulp_unit["version"] }

  generic_content_type 'python_package',
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentPackagesApi,
                       pulp3_model: PulpPythonClient::PythonPythonPackageContent,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename
  default_managed_content_type :python_package
end
