Katello::RepositoryTypeManager.register(::Katello::Repository::DEB_TYPE) do
  service_class Katello::Pulp::Repository::Deb
  prevent_unneeded_metadata_publish
  default_managed_content_type Katello::Deb
  content_type Katello::Deb, :pulp2_service_class => ::Katello::Pulp::Deb, :removable => true, :uploadable => true
end
