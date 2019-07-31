module Katello
  class ContentFacetApplicableDeb < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_facet, :inverse_of => :content_facet_applicable_debs, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :deb, :inverse_of => :content_facet_applicable_debs, :class_name => 'Katello::Deb'
  end
end
