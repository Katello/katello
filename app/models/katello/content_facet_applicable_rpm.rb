module Katello
  class ContentFacetApplicableRpm < Katello::Model
    belongs_to :content_facet, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :rpm, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Rpm'
  end
end
