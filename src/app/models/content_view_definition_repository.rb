class ContentViewDefinitionRepository < ActiveRecord::Base
  belongs_to :content_view_definition, :inverse_of => :content_view_definition_repositories
  belongs_to :repository, :inverse_of => :content_view_definition_repositories
end
