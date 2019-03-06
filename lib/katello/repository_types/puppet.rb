Katello::RepositoryTypeManager.register(::Katello::Repository::PUPPET_TYPE) do
  service_class Katello::Pulp::Repository::Puppet
  default_removable_type Katello::PuppetModule
  content_type Katello::PuppetModule, :pulp2_service_class => ::Katello::Pulp::PuppetModule, :removable => true, :uploadable => true
end
