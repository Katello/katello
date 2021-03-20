module Katello
  class ContentViewDebFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon

    belongs_to :filter,
               :class_name => "Katello::ContentViewDebFilter",
               :inverse_of => :deb_rules,
               :foreign_key => :content_view_filter_id

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
