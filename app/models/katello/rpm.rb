module Katello
  class Rpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::Rpm::CONTENT_TYPE

    has_many :repositories, :through => :repository_rpms, :class_name => "Katello::Repository"
    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :destroy, :inverse_of => :rpm

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :release, :complete_value => true
    scoped_search :on => :arch, :complete_value => true
    scoped_search :on => :epoch, :complete_value => true
    scoped_search :on => :filename, :complete_value => true
    scoped_search :on => :sourcerpm, :complete_value => true
    scoped_search :on => :checksum

    before_save lambda { |rpm| rpm.summary = rpm.summary.truncate(255) unless rpm.summary.blank? }

    def self.default_sort
      order(:name).order(:epoch).order(:version_sortable).order(:release_sortable)
    end

    def self.repository_association_class
      RepositoryRpm
    end

    def self.search_version_range(min = nil, max = nil)
      query = self.where(nil)
      query = Katello::Util::PackageFilter.new(query, min, Katello::Util::PackageFilter::GREATER_THAN).results if min
      query = Katello::Util::PackageFilter.new(query, max, Katello::Util::PackageFilter::LESS_THAN).results if max
      query
    end

    def self.search_version_equal(version)
      Katello::Util::PackageFilter.new(self, version, Katello::Util::PackageFilter::EQUAL).results
    end

    def update_from_json(json)
      keys = Pulp::Rpm::PULP_INDEXED_FIELDS - ['_id']
      custom_json = json.clone.delete_if { |key, _value| !keys.include?(key) }
      if custom_json.any? { |name, value| self.send(name) != value }
        custom_json[:release_sortable] = Util::Package.sortable_version(custom_json[:release])
        custom_json[:version_sortable] = Util::Package.sortable_version(custom_json[:version])
        self.update_attributes!(custom_json)
      end
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).uniq.count
    end

    def nvrea
      Util::Package.build_nvrea(self.as_json.with_indifferent_access, false)
    end

    def nvra
      Util::Package.build_nvra(self.as_json.with_indifferent_access)
    end
  end
end
