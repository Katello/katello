module Katello
  class ContentIndexSrpm < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_srpms, :class_name => 'Katello::ContentIndex'
    belongs_to :srpm, :class_name => 'Katello::Srpm', :inverse_of => :content_index_srpms
  end
end
