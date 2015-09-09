module Katello
  class ContentViewPackageGroupFilter < ContentViewFilter
    CONTENT_TYPE = PackageGroup::CONTENT_TYPE

    has_many :package_group_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                                   :class_name => "Katello::ContentViewPackageGroupFilterRule"
    validates_lengths_from_database

    def generate_clauses(_repo)
      package_group_ids = package_group_rules.reject { |rule| rule.uuid.blank? }.flat_map.map(&:uuid)
      { "_id" => { "$in" => package_group_ids } } unless package_group_ids.empty?
    end
  end
end
