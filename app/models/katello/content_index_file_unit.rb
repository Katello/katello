module Katello
  class ContentIndexFileUnit < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_file_units, :class_name => 'Katello::ContentIndex'
    belongs_to :file_unit, :class_name => 'Katello::FileUnit', :inverse_of => :content_index_file_units
  end
end
