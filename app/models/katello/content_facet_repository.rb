module Katello
  class ContentFacetRepository < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_facet, :inverse_of => :content_facet_repositories, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :repository, :inverse_of => :content_facet_repositories, :class_name => 'Katello::Repository'
  end
end
