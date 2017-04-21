module Katello
  class ContentFacetErratum < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_facet, :inverse_of => :content_facet_errata, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :erratum, :inverse_of => :content_facet_errata, :class_name => 'Katello::Erratum'
  end
end
