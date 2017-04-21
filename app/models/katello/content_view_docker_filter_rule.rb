module Katello
  class ContentViewDockerFilterRule < Katello::Model
    belongs_to :filter,
               :class_name => "Katello::ContentViewDockerFilter",
               :inverse_of => :docker_rules,
               :foreign_key => :content_view_filter_id

    validates_lengths_from_database
    validates :name, :presence => true
    validate :ensure_unique_attributes

    def ensure_unique_attributes
      other = self.class.where(:name => self.name,
                               :content_view_filter_id => self.content_view_filter_id)
      other = other.where.not(:id => self.id) if self.id
      if other.exists?
        errors.add(:base, "This docker manifest filter rule already exists.")
      end
    end
  end
end
