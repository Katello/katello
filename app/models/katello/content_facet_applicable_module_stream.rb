module Katello
  class ContentFacetApplicableModuleStream < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_facet, :inverse_of => :content_facet_applicable_rpms, :class_name => 'Katello::Host::ContentFacet'
    belongs_to :module_stream, :inverse_of => :content_facet_applicable_module_streams, :class_name => 'Katello::ModuleStream'
  end
end
