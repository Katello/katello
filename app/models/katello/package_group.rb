module Katello
  class PackageGroup < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = "package_group".freeze
    has_many :roots, :through => :repositories, :class_name => "Katello::RootRepository"

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :pulp_id, :rename => :id, :complete_value => true

    def repository
      self.repositories.first
    end

    def self.list_by_filter_clauses(clauses)
      package_names = []
      pulp_package_groups = Katello.pulp_server.extensions.package_group.search(Katello::PackageGroup::CONTENT_TYPE, :filters => clauses)
      groupings = [:default_package_names, :conditional_package_names, :optional_package_names, :mandatory_package_names]
      if pulp_package_groups.any?
        pulp_package_groups.flat_map { |group| groupings.each { |grouping| package_names << group[grouping] } }
        package_names.flatten!
      else
        []
      end
    end

    def package_names
      service_class = SmartProxy.pulp_primary!.content_service(CONTENT_TYPE)
      group = service_class.new(self.pulp_id)
      group.default_package_names + group.conditional_package_names + group.optional_package_names + group.mandatory_package_names
    end

    def content_view_package_group_filters
      Katello::ContentViewPackageGroupFilter.joins(:package_groups).where("#{self.class.table_name}.pulp_id" => self.pulp_id)
    end
  end
end
