module Katello
  class ContentFacetApplicableRpm < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_facet, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :rpm, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Rpm'
  end
end
