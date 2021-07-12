module Katello
  class RepositoryGenericContentUnit < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_generic_content_units, :class_name => 'Katello::Repository'
    belongs_to :generic_content_unit, :inverse_of => :repository_generic_content_units, :class_name => 'Katello::GenericContentUnit'
  end
end
