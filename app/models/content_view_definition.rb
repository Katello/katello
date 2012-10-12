class ContentViewDefinition < ActiveRecord::Base
  has_many :content_views
  belongs_to :organization

  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
end
