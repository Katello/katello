class ComponentContentView < ActiveRecord::Base
  belongs_to :content_view_definition
  belongs_to :content_view
end
