class ContentViewComponent < ActiveRecord::Base
  belongs_to :composite, :class_name => "ContentView", :foreign_key => :composite_id
  belongs_to :component, :class_name => "ContentView", :foreign_key => :component_id
end
