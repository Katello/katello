module Katello
  class ContentFacetApplicableRpm < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_facet, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :rpm, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Rpm'
  end
end
