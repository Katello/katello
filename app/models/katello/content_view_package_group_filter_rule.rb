module Katello
  class ContentViewPackageGroupFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageGroupFilter",
               :inverse_of => :package_group_rules,
               :foreign_key => :content_view_filter_id

    has_one :package_group,
            class_name: "Katello::PackageGroup",
            foreign_key: :pulp_id,
            primary_key: :uuid,
            dependent: :nullify

    validates :uuid, :presence => true, :uniqueness => { :scope => :content_view_filter_id }
  end
end
