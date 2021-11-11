module Katello
  class ContentViewPackageFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageFilter",
               :inverse_of => :package_rules,
               :foreign_key => :content_view_filter_id

    validates :name, :presence => true
    validate :ensure_unique_attributes
    validates_with Validators::ContentViewFilterVersionValidator
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :min_version, :complete_value => true
    scoped_search :on => :max_version, :complete_value => true
    scoped_search :on => :architecture, :complete_value => true

    def ensure_unique_attributes
      other = self.class.where(:name => self.name,
                               :version => self.version,
                               :content_view_filter_id => self.content_view_filter_id,
                               :min_version => self.min_version,
                               :max_version => self.max_version,
                               :architecture => self.architecture)
      other = other.where.not(:id => self.id) if self.id
      if other.exists?
        errors.add(:base, "This package filter rule already exists.")
      end
    end
  end
end
