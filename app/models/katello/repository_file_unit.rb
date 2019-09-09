module Katello
  class RepositoryFileUnit < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_file_units, :class_name => 'Katello::Repository'
    belongs_to :file_unit, :inverse_of => :repository_file_units, :class_name => 'Katello::FileUnit'
  end
end
