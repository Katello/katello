class ContentView < ActiveRecord::Base
  belongs_to :content_view_definition
  belongs_to :organization
  has_many :environment_defaults, :class_name => "KTEnvironment",
    :inverse_of => :default_content_view,
    :foreign_key => :default_content_view_id

  has_many :environment_content_views
  has_many :environments, :through => :environment_content_views,
    :class_name => "KTEnvironment"

  has_many :content_view_components, :foreign_key => :composite_id
  has_many :component_content_views, :through => :content_view_components,
    :source => :component

  has_many :content_view_composites, :class_name => "ContentViewComponent",
    :inverse_of => :component, :foreign_key => :component_id
  has_many :composite_content_views, :through => :content_view_composites,
    :source => :composite

  validates :name, :presence => true

  def as_json options = {}
    result = self.attributes
    result['organization'] = self.organization.try(:name)
    result
  end
end
