module Katello
  class ContentIndexDeb < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_debs, :class_name => 'Katello::ContentIndex'
    belongs_to :deb, :class_name => 'Katello::Deb', :inverse_of => :content_index_debs
  end
end
