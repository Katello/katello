# encoding: utf-8

module Support
  class HostSupport
    def self.setup_host_for_view(host, view, environment, assign_to_puppet)
      puppet_env = ::Environment.create!(:name => 'blahblah')

      cvpe = view.version(environment).puppet_env(environment)
      cvpe.puppet_environment = puppet_env
      cvpe.save!

      host.content_aspect = Katello::Host::ContentAspect.new(:content_view => view, :lifecycle_environment => environment)
      host.update_column(:environment_id, cvpe.puppet_environment.id) if assign_to_puppet
      host.reload
    end
  end
end
