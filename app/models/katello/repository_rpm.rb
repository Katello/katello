module Katello
  class RepositoryRpm < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_rpms, :class_name => 'Katello::Repository'
    belongs_to :rpm, :inverse_of => :repository_rpms, :class_name => 'Katello::Rpm'
  end
end
