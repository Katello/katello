module Katello
  class RepositoryModuleStream < ApplicationRecord
    belongs_to :repository, inverse_of: :repository_module_stream, class_name: 'Katello::Repository'
    belongs_to :module_stream, inverse_of: :repository_module_stream, class_name: 'Katello::ModuleStream'
  end
end
