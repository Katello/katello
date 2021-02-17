module Katello
  class ContentViewPackageGroupFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageGroupFilter",
               :inverse_of => :package_group_rules,
               :foreign_key => :content_view_filter_id

    belongs_to :package_group,
               class_name: "Katello::PackageGroup",
               inverse_of: :content_view_filter_rules,
               primary_key: :uuid,
               foreign_key: :pulp_id

    validates :uuid, :presence => true, :uniqueness => { :scope => :content_view_filter_id }
  end
end
