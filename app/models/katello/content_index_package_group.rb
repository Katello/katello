module Katello
  class ContentIndexPackageGroup < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_package_groups, :class_name => 'Katello::ContentIndex'
    belongs_to :package_group, :class_name => 'Katello::PackageGroup', :inverse_of => :content_index_package_groups
  end
end
