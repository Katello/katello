class ContentViewDefinitionProduct < ActiveRecord::Base
  belongs_to :content_view_definition
  belongs_to :product
end
