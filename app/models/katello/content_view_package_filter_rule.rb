module Katello
  class ContentViewPackageFilterRule < Katello::Model
    self.include_root_in_json = false

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageFilter",
               :inverse_of => :package_rules,
               :foreign_key => :content_view_filter_id

    validates_lengths_from_database
    validates :name, :presence => true
    validates_with Validators::ContentViewFilterVersionValidator
  end
end
