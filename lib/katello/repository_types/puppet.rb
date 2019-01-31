Katello::RepositoryTypeManager.register(::Katello::Repository::PUPPET_TYPE) do
  service_class Katello::Pulp::Repository::Puppet
  content_type Katello::PuppetModule, :pulp2_service_class => ::Katello::Pulp::PuppetModule, :user_removable => true
end
