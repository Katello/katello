require 'pulp_python_client'

Katello::RepositoryTypeManager.register('python') do
  allow_creation_by_user true
  pulp3_service_class Katello::Pulp3::Repository::Generic
  pulp3_api_class Katello::Pulp3::Api::Generic
  pulp3_plugin 'python'

  client_module_class PulpPythonClient
  api_class PulpPythonClient::ApiClient
  configuration_class PulpPythonClient::Configuration
  remote_class PulpPythonClient::PythonPythonRemote
  remotes_api_class PulpPythonClient::RemotesPythonApi
  repositories_api_class PulpPythonClient::RepositoriesPythonApi
  repository_versions_api_class PulpPythonClient::RepositoriesPythonVersionsApi
  distributions_api_class PulpPythonClient::DistributionsPypiApi
  distribution_class PulpPythonClient::PythonPythonDistribution
  publication_class PulpPythonClient::PythonPythonPublication
  publications_api_class PulpPythonClient::PublicationsPypiApi
  repo_sync_url_class PulpPythonClient::RepositorySyncURL

  generic_remote_option :includes, title: N_("Includes"), type: Array, input_type: "textarea", delimiter: "\\n",
                        description: N_("Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.")

  generic_remote_option :excludes, title: N_("Excludes"), type: Array, input_type: "textarea", delimiter: "\\n",
                        description: N_("Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.")

  generic_remote_option :package_types, title: N_("Package Types"), type: Array, input_type: "text", delimiter: ",",
                        description: N_("Package types to sync for Python content, separated by comma. Leave empty to get every package type. Package types are: bdist_dmg, bdist_dumb, bdist_egg, bdist_msi, bdist_rpm, bdist_wheel, bdist_wininst, sdist.")

  url_description N_("URL of a PyPI content source such as https://pypi.org.")

  generic_content_type 'python_package',
                       pluralized_name: "Python Packages",
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpPythonClient::ContentPackagesApi,
                       pulp3_model: PulpPythonClient::PythonPythonPackageContent,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       model_name: lambda { |pulp_unit| pulp_unit["name"] },
                       model_version: lambda { |pulp_unit| pulp_unit["version"] },
                       model_filename: lambda { |pulp_unit| pulp_unit["filename"] },
                       model_additional_metadata: lambda { |pulp_unit|
                         {
                           "package_type": pulp_unit["packagetype"],
                           "sha256": pulp_unit["sha256"]
                         }
                       },
                       removable: true,
                       uploadable: true,
                       duplicates_allowed: false,
                       filename_key: :filename,
                       generic_browser: true,
                       test_upload_path: 'test/fixtures/files/shelf_reader-0.1-py2-none-any.whl'
  default_managed_content_type :python_package

  test_url 'https://fixtures.pulpproject.org/python-pypi/'
  test_url_root_options generic_remote_options: {includes: ['celery']}.to_json
end
