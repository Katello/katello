module Katello
  class RepositoryOstreeBranch < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_ostree_branches, :class_name => 'Katello::Repository'
    belongs_to :ostree_branch, :inverse_of => :repository_ostree_branches
  end
end
