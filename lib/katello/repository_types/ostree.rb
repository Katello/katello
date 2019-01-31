Katello::RepositoryTypeManager.register(::Katello::Repository::OSTREE_TYPE) do
  service_class Katello::Pulp::Repository::Ostree
  content_type Katello::OstreeBranch, :pulp2_service_class => ::Katello::Pulp::OstreeBranch, :user_removable => true
end
