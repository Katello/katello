Katello::RepositoryTypeManager.register(::Katello::Repository::DEB_TYPE) do
  service_class Katello::Pulp::Repository::Deb
  pulp3_service_class Katello::Pulp3::Repository::Apt
  pulp3_api_class Katello::Pulp3::Api::Apt
  pulp3_plugin 'pulp_deb'
  prevent_unneeded_metadata_publish

  default_managed_content_type Katello::Deb
  content_type Katello::Deb,
    :pulp2_service_class => ::Katello::Pulp::Deb,
    :pulp3_service_class => ::Katello::Pulp3::Deb,
    :removable => true,
    :uploadable => true
end
