module Katello
  class ContentViewPackageFilter < ContentViewFilter
    CONTENT_TYPE = Package::CONTENT_TYPE

    has_many :package_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewPackageFilterRule"
    validates_lengths_from_database

    # Returns a set of Pulp/MongoDB conditions to filter out packages in the
    # repo repository that match parameters
    #
    # @param repo [Repository] a repository containing packages to filter
    # @return [Array] an array of hashes with MongoDB conditions
    def generate_clauses(repo)
      package_filenames = package_rules.reject { |rule| rule.name.blank? }.flat_map do |rule|
        filter = version_filter(rule)
        Package.legacy_search(rule.name, 0, repo.package_count, [repo.pulp_id], [:nvrea_sort, "asc"],
                       :all, 'name', filter).map(&:filename).compact
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

    def version_filter(rule)
      if !rule.version.blank?
        Util::Package.version_eq_filter(rule.version)
      elsif !rule.min_version.blank? || !rule.max_version.blank?
        Util::Package.version_filter(rule.min_version, rule.max_version)
      end
    end
  end
end
