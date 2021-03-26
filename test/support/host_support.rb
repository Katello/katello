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
  end
end
