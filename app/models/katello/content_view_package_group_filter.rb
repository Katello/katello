module Katello
  class ContentViewPackageGroupFilter < ContentViewFilter
    CONTENT_TYPE = PackageGroup::CONTENT_TYPE

    has_many :package_group_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                                   :class_name => "Katello::ContentViewPackageGroupFilterRule"
    has_many :package_groups,
             through: :package_group_rules,
             class_name: "Katello::PackageGroup"

    validates_lengths_from_database

    def generate_clauses(_repo)
      package_group_ids = package_group_rules.reject { |rule| rule.uuid.blank? }.flat_map.map(&:uuid)
      { "_id" => { "$in" => package_group_ids } } unless package_group_ids.empty?
    end

    def content_unit_pulp_ids(repo)
      package_group_hrefs = package_group_rules.reject { |rule| rule.uuid.blank? }.flat_map.map(&:uuid)
      package_group_names = repo.package_groups.
        where(:pulp_id => package_group_hrefs).collect { |package_group| package_group.package_names }.flatten.uniq
      repo.rpms.where(:name => package_group_names).pluck(:pulp_id).compact
    end
  end
end
