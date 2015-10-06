module Katello
  class ContentAspectErratum < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_aspect, :inverse_of => :content_aspect_errata, :class_name => 'Katello::Host::ContentAspect'
    belongs_to :erratum, :inverse_of => :content_aspect_errata, :class_name => 'Katello::Erratum'
  end
end
