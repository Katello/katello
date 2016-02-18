# encoding: utf-8

module Support
  class HostSupport
    def self.attach_content_facet(host, view, environment)
      content_facet = Katello::Host::ContentFacet.new
      content_facet.content_view = view
      content_facet.lifecycle_environment = environment
      host.content_facet = content_facet
      host.reload
    end

    def self.setup_host_for_view(host, view, environment, assign_to_puppet)
      puppet_env = ::Environment.create!(:name => 'blahblah')

      cvpe = view.version(environment).puppet_env(environment)
      cvpe.puppet_environment = puppet_env
      cvpe.save!

      attach_content_facet(host, view, environment)

      host.update_column(:environment_id, cvpe.puppet_environment.id) if assign_to_puppet
      host.reload
    end
  end
end
