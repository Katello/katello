# encoding: utf-8

module Support
  class HostSupport
    def self.attach_content_facet(host, view, environment)
      content_facet = Katello::Host::ContentFacet.new
      cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(view.id, environment.id)
      content_facet.content_view_environments = [cvenv]
      host.content_facet = content_facet
      host.reload
    end
  end
end
