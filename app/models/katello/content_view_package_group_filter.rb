module Katello
  class ContentViewPackageGroupFilter < ContentViewFilter
    use_index_of ContentViewFilter if Katello.config.use_elasticsearch

    CONTENT_TYPE = PackageGroup::CONTENT_TYPE

    has_many :package_group_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                                   :class_name => "Katello::ContentViewPackageGroupFilterRule"
    validates_lengths_from_database

    def generate_clauses(repo)
      package_group_ids = package_group_rules.reject { |rule| rule.uuid.blank? }.flat_map do |rule|
        PackageGroup.legacy_search(rule.uuid, 0, 0, [repo.pulp_id], [:name_sort, "asc"], 'id').map(&:package_group_id).compact
      end
      { "id" => { "$in" => package_group_ids } } unless package_group_ids.empty?
    end
  end
end
