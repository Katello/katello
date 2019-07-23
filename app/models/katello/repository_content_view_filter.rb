module Katello
  class RepositoryContentViewFilter < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_content_view_filters, :class_name => 'Katello::Repository'
    belongs_to :filter, :inverse_of => :repository_content_view_filters, :class_name => 'Katello::ContentViewFilter', :foreign_key => :content_view_filter_id
  end
end
