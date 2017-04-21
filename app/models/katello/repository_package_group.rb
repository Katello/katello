module Katello
  class RepositoryPackageGroup < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_package_groups, :class_name => 'Katello::Repository'
    belongs_to :package_group, :inverse_of => :repository_package_groups, :class_name => 'Katello::PackageGroup'
  end
end
