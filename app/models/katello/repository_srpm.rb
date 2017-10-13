module Katello
  class RepositorySrpm < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_srpms, :class_name => 'Katello::Repository'
    belongs_to :srpm, :inverse_of => :repository_srpms, :class_name => 'Katello::Srpm'
  end
end
