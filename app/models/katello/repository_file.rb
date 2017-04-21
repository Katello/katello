module Katello
  class RepositoryFile < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_files, :class_name => 'Katello::Repository'
    belongs_to :file, :inverse_of => :repository_files, :class_name => 'Katello::FileUnit', :foreign_key => :file_id
  end
end
