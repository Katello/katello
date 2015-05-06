module Katello
  class RepositoryErratum < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_errata, :class_name => 'Katello::Repository'
    belongs_to :erratum, :inverse_of => :repository_errata, :class_name => 'Katello::Erratum'
  end
end
