Katello::RepositoryTypeManager.register(::Katello::Repository::OSTREE_TYPE) do
  service_class Katello::Pulp::Repository::Ostree
  default_managed_content_type Katello::OstreeBranch::CONTENT_TYPE
  content_type Katello::OstreeBranch, :pulp2_service_class => ::Katello::Pulp::OstreeBranch, :removable => true, :uploadable => true
end
