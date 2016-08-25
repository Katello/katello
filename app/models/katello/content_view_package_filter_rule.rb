module Katello
  class ContentViewPackageFilterRule < Katello::Model
    self.include_root_in_json = false

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageFilter",
               :inverse_of => :package_rules,
               :foreign_key => :content_view_filter_id

    validates_lengths_from_database
    validates :name, :presence => true
    validate :ensure_unique_attributes
    validates_with Validators::ContentViewFilterVersionValidator

    def ensure_unique_attributes
      other = self.class.where(:name => self.name,
                               :version => self.version,
                               :content_view_filter_id => self.content_view_filter_id,
                               :min_version => self.min_version,
                               :max_version => self.max_version)
      other = other.where.not(:id => self.id) if self.id
      if other.exists?
        errors.add(:base, "This package filter rule already exists.")
      end
    end
  end
end
