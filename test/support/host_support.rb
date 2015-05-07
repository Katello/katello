# encoding: utf-8

module Support
  class HostSupport
    def self.setup_host_for_view(host, view, environment, assign_to_puppet)
      puppet_env = ::Environment.create!(:name => 'blahblah')

      cvpe = view.version(environment).puppet_env(environment)
      cvpe.puppet_environment = puppet_env
      cvpe.save!

      host.update_column(:content_view_id, view.id)
      host.update_column(:lifecycle_environment_id, environment.id)
      host.update_column(:environment_id, cvpe.puppet_environment.id) if assign_to_puppet
    end
  end
end
