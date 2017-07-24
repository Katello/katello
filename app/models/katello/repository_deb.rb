module Katello
  class RepositoryDeb < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_debs, :class_name => 'Katello::Repository'
    belongs_to :deb, :inverse_of => :repository_debs, :class_name => 'Katello::Deb'
  end
end
