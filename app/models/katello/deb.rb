module Katello
  class Deb < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::Deb::CONTENT_TYPE

    has_many :repositories, :through => :repository_debs, :class_name => "Katello::Repository"
    has_many :repository_debs, :class_name => "Katello::RepositoryDeb", :dependent => :destroy, :inverse_of => :deb

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :architecture, :complete_value => true
    scoped_search :on => :filename, :complete_value => true
    scoped_search :on => :checksum

    before_save lambda { |deb| deb.description = deb.description.truncate(255) unless deb.description.blank? }

    def self.default_sort
      order(:name).order(:version).order(:architecture)
    end

    def self.repository_association_class
      RepositoryDeb
    end

    def self.search_version_range(min = nil, max = nil)
      query = self.all
      query = Katello::Util::PackageFilter.new(query, min, Katello::Util::PackageFilter::GREATER_THAN).results if min
      query = Katello::Util::PackageFilter.new(query, max, Katello::Util::PackageFilter::LESS_THAN).results if max
      query
    end

    def self.search_version_equal(version)
      Katello::Util::PackageFilter.new(self, version, Katello::Util::PackageFilter::EQUAL).results
    end

    def update_from_json(json)
      keys = Pulp::Deb::PULP_INDEXED_FIELDS - ['_id']
      custom_json = json.slice(*keys)
      if custom_json.any? { |name, value| self.send(name) != value }
        self.assign_attributes(custom_json)
        self.save!
      end
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).uniq.count
    end
  end
end
