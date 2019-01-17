# Registering a new repository type

Full example:

```ruby

Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
  service_class Katello::Pulp::Repository::Yum
  prevent_unneeded_metadata_publish

  content_type Katello::Rpm, :priority => 1, :pulp2_service_class => ::Katello::Pulp::Rpm
  content_type Katello::Erratum, :priority => 2, :pulp2_service_class => ::Katello::Pulp::Erratum
  content_type Katello::ModuleStream, :priority => 3, :pulp2_service_class => ::Katello::Pulp::ModuleStream
  content_type Katello::PackageGroup, :pulp2_service_class => ::Katello::Pulp::PackageGroup
  content_type Katello::YumMetadataFile, :pulp2_service_class => ::Katello::Pulp::YumMetadataFile
  content_type Katello::Srpm, :pulp2_service_class => ::Katello::Pulp::Srpm

  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
end

```

## DSL breakdown

### Declaration
```ruby
Katello::RepositoryTypeManager.register(::Katello::Repository::YUM_TYPE) do
```
This declares the the repository type, specifying a type identifier (e.g. 'yum')

### Service class

```ruby
  service_class Katello::Pulp::Repository::Yum
```

Identifies the service class that is used to interface with pulp 2 and includes methods for creating and updating the type of repository
 
 ### Content Type
 
```ruby
  content_type Katello::Rpm, :priority => 1, :pulp2_service_class => ::Katello::Pulp::Rpm
```

Defines a content type to be used by the repository.  The first argument is the Active Record model class representing the content type.  This should extend the `Katello::Concerns::PulpDatabaseUnit` class.
The second argument is an options hash that includes:
* priority - The ordering used when indexing or performing other operations (1 is highest, defaults to 99)
* pulp2_service_class - The service class representing this content type in pulp 2

### Additional custom indexing

```ruby
  index_additional_data { |repo, target_repo = nil| repo.import_distribution_data(target_repo) }
```

Provides a block that will be executed after other repository indexing completes.

### Indexing optimizations

```ruby
prevent_unneeded_metadata_publish
```

This option declares that this content type supports the CheckMatchingContent middleware where by repositories are not actually republished in pulp if no content changes.