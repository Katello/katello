# Registering a new repository type

# Full example:

```ruby
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
    priority: 1,
    pulp3_service_class: ::Katello::Pulp3::Rpm,
    primary_content: true,
    removable: true,
    uploadable: true
  content_type Katello::ModuleStream,
    priority: 2,
    pulp3_service_class: ::Katello::Pulp3::ModuleStream
  content_type Katello::Erratum, priority: 3,
    pulp3_service_class: ::Katello::Pulp3::Erratum,
    primary_content: true, mutable: true
  content_type Katello::PackageGroup,
    pulp3_service_class: ::Katello::Pulp3::PackageGroup
  content_type Katello::Srpm,
    pulp3_service_class: ::Katello::Pulp3::Srpm,
    removable: true, uploadable: true
  content_type Katello::Distribution, priority: 4,
    pulp3_service_class: ::Katello::Pulp3::Distribution,
    index: false
  content_type Katello::PackageCategory, priority: 4, index: false

  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
end
```

## DSL breakdown

### Declaration
```ruby
Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
```
This declares the the repository type, specifying a type identifier (e.g. 'yum')

### Service class and friends

```ruby
  pulp3_service_class Katello::Pulp3::Repository::Yum
  pulp3_api_class Katello::Pulp3::Api::Yum
  pulp3_plugin 'rpm'
  ...
```

Identifies the service class that is used to interface with Pulp and includes methods for creating and updating the type of repository. Also notes the location of the main API class and the name of the corresponding Pulp plugin.
There are a number of other classes that need to be defined, so follow the [full example](full-example) above to ensure that the new type has
all the neccessary information.

 ### Content Type

```ruby
  default_managed_content_type Katello::Rpm::CONTENT_TYPE
  content_type Katello::Rpm,
    priority: 1,
    pulp3_service_class: ::Katello::Pulp3::Rpm,
    primary_content: true,
    removable: true,
    uploadable: true
```

The `default_managed_content_type` method sets the Rpm content type as the default content type, which
the repository type will act upon when another content type is not explicitly declared. For example, a yum upload
will assume that the uploaded content is of Rpm type unless otherwise specified.

The `content_type` method defines a content type to be used by the repository.  The first argument is the Active Record model class representing the content type.  This should extend the `Katello::Concerns::PulpDatabaseUnit` class.
The second argument is an options hash that includes:
* priority - The ordering used when indexing or performing other operations (1 is highest, defaults to 99)
* pulp3_service_class - The service class representing this content type
* primary_content - The indexing of this content type is recorded for display after syncing
* removable - Content units of this type can be deleted from a repository
* uploadable - Content units of this type can be uploaded to a repository
* index - Content units of this type will be indexed


### Additional custom indexing

```ruby
  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
```

Provides a block that will be executed after other repository indexing completes.

### Indexing optimizations

```ruby
prevent_unneeded_metadata_publish
```

This option declares that this content type supports the CheckMatchingContent middleware, which removes the need to republish repositories in Pulp when content doesn't change.

### Generic content types

For content types that are simple enough to support it, the "generic content type" framework can be used.
If no special models are required to support the new content type, the only information that needs to be added
about the type would be what exists in the repository type definition.
The `generic_content_type` and `generic_remote_option` methods exist to define all other attributes that are needed to
create a generic type.
To create a generic content type, follow the Python type as an example:

```ruby
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

  generic_remote_option :includes, title: N_("Includes"), type: Array, input_type: "textarea", delimiter: "\\n", default: [],
                        description: N_("Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.")

  generic_remote_option :excludes, title: N_("Excludes"), type: Array, input_type: "textarea", delimiter: "\\n", default: [],
                        description: N_("Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.")

  generic_remote_option :package_types, title: N_("Package Types"), type: Array, input_type: "text", delimiter: ",", default: [],
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
```