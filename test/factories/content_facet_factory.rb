FactoryGirl.define do
  factory :katello_content_facets, :aliases => [:content_facet], :class => ::Katello::Host::ContentFacet do
    sequence(:uuid) { |n| "uuid-#{n}" }
  end
end
