module Katello
  class ContentIndexGenericContentUnit < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_generic_content_units, :class_name => 'Katello::ContentIndex'
    belongs_to :generic_content_unit, :class_name => 'Katello::GenericContentUnit', :inverse_of => :content_index_generic_content_units
  end
end
