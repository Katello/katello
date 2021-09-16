require 'pulp_ostree_client'

Katello::RepositoryTypeManager.register('ostree') do
  allow_creation_by_user true
  pulp3_service_class Katello::Pulp3::Repository::Generic
  pulp3_api_class Katello::Pulp3::Api::Generic
  pulp3_plugin 'python'
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

  generic_remote_option :includes, title: N_("Includes"), type: Array, input_type: "textarea", delimiter: "\\n",
                        description: N_("Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.")

  generic_remote_option :excludes, title: N_("Excludes"), type: Array, input_type: "textarea", delimiter: "\\n",
                        description: N_("Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.")

  generic_remote_option :package_types, title: N_("Package Types"), type: Array, input_type: "text", delimiter: ",",
                        description: N_("Package types to sync for Python content, separated by comma. Leave empty to get every package type. Package types are: bdist_dmg, bdist_dumb, bdist_egg, bdist_msi, bdist_rpm, bdist_wheel, bdist_wininst, sdist.")

  url_description N_("URL of a PyPI content source such as https://pypi.org.")

  model_name lambda { |pulp_unit| pulp_unit["name"] }
  model_version lambda { |pulp_unit| pulp_unit["version"] }

  generic_content_type 'ostree_commit',
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentCommitsApi,
                       pulp3_model: PulpPythonClient::OstreeOstree,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename

  generic_content_type 'ostree_ref',
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentRefsApi,
                       pulp3_model: PulpPythonClient::PythonPythonPackageContent,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename

  generic_content_type 'ostree_config',
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentConfigsApi,
                       pulp3_model: PulpPythonClient::PythonPythonPackageContent,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename

  generic_content_type 'ostree_summary',
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentSummariesApi,
                       pulp3_model: PulpPythonClient::ContentSummary,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename

  default_managed_content_type :python_package
end
