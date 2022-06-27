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

    def package_names
      service_class = SmartProxy.pulp_primary!.content_service(CONTENT_TYPE)
      group = service_class.new(self.pulp_id)
      group.default_package_names + group.conditional_package_names + group.optional_package_names + group.mandatory_package_names
    end

    def content_view_filters
      Katello::ContentViewPackageGroupFilterRule.where(uuid: self.pulp_id).eager_load(:filter).map(&:filter)
    end
  end
end
