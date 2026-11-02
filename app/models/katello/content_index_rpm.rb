module Katello
  class ContentIndexRpm < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_rpms, :class_name => 'Katello::ContentIndex'
    belongs_to :rpm, :class_name => 'Katello::Rpm', :inverse_of => :content_index_rpms
  end
end
