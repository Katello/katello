module Katello
  class ContentIndexErratum < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_errata, :class_name => 'Katello::ContentIndex'
    belongs_to :erratum, :class_name => 'Katello::Erratum', :inverse_of => :content_index_errata
  end
end
