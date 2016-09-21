module Katello
  class Rpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::Rpm::CONTENT_TYPE

    has_many :repositories, :through => :repository_rpms, :class_name => "Katello::Repository"
    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :destroy, :inverse_of => :rpm

    has_many :content_facets, :through => :content_facet_applicable_rpms, :class_name => "Katello::Host::ContentFacet"
    has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm",
             :dependent => :destroy, :inverse_of => :rpm

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
      query = self.all
      query = Katello::Util::PackageFilter.new(query, min, Katello::Util::PackageFilter::GREATER_THAN).results if min
      query = Katello::Util::PackageFilter.new(query, max, Katello::Util::PackageFilter::LESS_THAN).results if max
      query
    end

    def self.search_version_equal(version)
      Katello::Util::PackageFilter.new(self, version, Katello::Util::PackageFilter::EQUAL).results
    end

    def update_from_json(json)
      keys = Pulp::Rpm::PULP_INDEXED_FIELDS - ['_id']
      custom_json = json.slice(*keys)
      if custom_json.any? { |name, value| self.send(name) != value }
        custom_json[:release_sortable] = Util::Package.sortable_version(custom_json[:release])
        custom_json[:version_sortable] = Util::Package.sortable_version(custom_json[:version])
        self.assign_attributes(custom_json)
        self.nvra = self.build_nvra
        self.save!
      end
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).uniq.count
    end

    def nvrea
      Util::Package.build_nvrea(self.attributes.with_indifferent_access, false)
    end

    def build_nvra
      Util::Package.build_nvra(self.attributes.with_indifferent_access)
    end

    def hosts_applicable(org_id = nil)
      if org_id.present?
        self.content_facets.joins(:host).where("#{::Host.table_name}.organization_id" => org_id)
      else
        self.content_facets.joins(:host)
      end
    end

    def hosts_available(org_id = nil)
      self.hosts_applicable(org_id).joins("INNER JOIN #{Katello::RepositoryRpm.table_name} on \
        #{Katello::RepositoryRpm.table_name}.rpm_id = #{self.id}").joins(:content_facet_repositories).
        where("#{Katello::ContentFacetRepository.table_name}.repository_id = #{Katello::RepositoryRpm.table_name}.repository_id").uniq
    end

    def self.installable_for_hosts(hosts = nil)
      query = Katello::Rpm.joins(:content_facet_applicable_rpms).joins(:repository_rpms).
        joins("INNER JOIN #{Katello::ContentFacetRepository.table_name} on \
        #{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::ContentFacetApplicableRpm.table_name}.content_facet_id").
        joins("INNER JOIN #{Katello::RepositoryRpm.table_name} AS host_repo_rpm ON \
          host_repo_rpm.rpm_id = #{Katello::Rpm.table_name}.id").
        where("#{Katello::ContentFacetRepository.table_name}.repository_id = host_repo_rpm.repository_id")

      query = query.joins(:content_facets).where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts.map(&:id)) if hosts
      query.uniq
    end

    def self.applicable_to_hosts(hosts)
      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts).uniq
    end
  end
end
