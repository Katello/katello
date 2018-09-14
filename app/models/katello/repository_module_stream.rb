module Katello
  class RepositoryModuleStream < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, inverse_of: :repository_module_streams, class_name: 'Katello::Repository'
    belongs_to :module_stream, inverse_of: :repository_module_streams, class_name: 'Katello::ModuleStream'
  end
end
