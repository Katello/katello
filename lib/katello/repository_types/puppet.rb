Katello::RepositoryTypeManager.register(::Katello::Repository::PUPPET_TYPE) do
  service_class Katello::Pulp::Repository::Puppet
end
