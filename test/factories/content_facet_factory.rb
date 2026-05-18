FactoryBot.define do
  factory :katello_content_facets, :aliases => [:content_facet], :class => ::Katello::Host::ContentFacet do
    # UUID removed - it belongs to subscription_facet, not content_facet
  end
end
