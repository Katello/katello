module Katello
  class ContentIndexModuleStream < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_module_streams, :class_name => 'Katello::ContentIndex'
    belongs_to :module_stream, :class_name => 'Katello::ModuleStream', :inverse_of => :content_index_module_streams
  end
end
