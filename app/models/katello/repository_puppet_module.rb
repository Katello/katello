module Katello
  class RepositoryPuppetModule < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_puppet_modules, :class_name => 'Katello::Repository'
    belongs_to :puppet_module, :inverse_of => :repository_puppet_modules, :class_name => 'Katello::PuppetModule'
  end
end
