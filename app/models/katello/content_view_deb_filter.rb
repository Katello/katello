module Katello
  class ContentViewDebFilter < ContentViewFilter
    CONTENT_TYPE = Deb::CONTENT_TYPE

    has_many :deb_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                                   :class_name => "Katello::ContentViewDebFilterRule"
    validates_lengths_from_database

    def generate_clauses(repo)
      package_filenames = []

      self.deb_rules.each do |rule|
        package_filenames.concat(query_debs(repo, rule))
      end

      package_filenames = package_filenames.uniq.sort

      ContentViewDebFilter.generate_deb_clauses(package_filenames)
    end

    def content_unit_pulp_ids(repo)
      deb_filenames = []
      self.deb_rules.each do |rule|
        deb_filenames.concat(query_debs(repo, rule))
      end

      deb_filenames = deb_filenames.uniq

      debs = Deb.in_repositories(repo)
      debs.where(filename: deb_filenames).pluck(:pulp_id).flatten.uniq
    end

    def self.generate_deb_clauses(package_filenames = [])
      { 'filename' => { "$in" => package_filenames } } unless package_filenames.empty?
    end

    def applicable_debs
      Deb.in_repositories(self.applicable_repos)
    end

    def query_debs(repo, rule)
      debs = Deb.in_repositories(repo)
      query_debs_from_collection(debs, rule).pluck("#{Deb.table_name}.filename")
    end

    def query_debs_from_collection(collection, rule)
      query_name = rule.name.tr("*", "%")
      query = collection.where("#{Deb.table_name}.name ilike ?", query_name)
      if rule.architecture.present?
        query_arch = rule.architecture.tr("*", "%")
        query = query.where("#{Deb.table_name}.architecture ilike ?", query_arch)
      end
      if rule.version.present?
        query = query.search_version_equal(rule.version)
      elsif rule.min_version.present? || rule.max_version.present?
        query = query.search_version_range(rule.min_version, rule.max_version)
      end
      query.default_sort
    end
  end
end
