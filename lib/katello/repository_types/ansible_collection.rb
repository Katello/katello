Katello::RepositoryTypeManager.register(::Katello::Repository::ANSIBLE_COLLECTION_TYPE) do
  allow_creation_by_user true
  pulp3_skip_publication true
  pulp3_service_class Katello::Pulp3::Repository::AnsibleCollection
  pulp3_api_class Katello::Pulp3::Api::AnsibleCollection
  pulp3_plugin 'ansible'

  content_type Katello::AnsibleCollection, :pulp3_service_class => ::Katello::Pulp3::AnsibleCollection, :user_removable => true
end
