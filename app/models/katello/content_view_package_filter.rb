module Katello
  class ContentViewPackageFilter < ContentViewFilter
    CONTENT_TYPE = Rpm::CONTENT_TYPE

    has_many :package_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewPackageFilterRule"
    validates_lengths_from_database

    # Returns a set of Pulp/MongoDB conditions to filter out packages in the
    # repo repository that match parameters
    #
    # @param repo [Repository] a repository containing packages to filter
    # @return [Array] an array of hashes with MongoDB conditions
    def generate_clauses(repo)
      package_filenames = []

      self.package_rules.each do |rule|
        package_filenames.concat(query_rpms(repo, rule))
      end
      if self.original_packages
        package_filenames.concat(repo.packages_without_errata.map(&:filename))
      end

      { 'filename' => { "$in" => package_filenames } } unless package_filenames.empty?
    end

    def original_packages=(value)
      self[:original_packages] = value
    end

    protected

    def query_rpms(repo, rule)
      query_name = rule.name.tr("*", "%")
      query = Rpm.in_repositories(repo).where("#{Rpm.table_name}.name ilike ?", query_name)
      if !rule.version.blank?
        query = query.search_version_equal(rule.version)
      elsif !rule.min_version.blank? || !rule.max_version.blank?
        query = query.search_version_range(rule.min_version, rule.max_version)
      end
      query.pluck("#{Rpm.table_name}.filename")
    end
  end
end
