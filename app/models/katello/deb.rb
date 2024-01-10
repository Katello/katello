module Katello
  class Deb < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = 'deb'.freeze

    has_many :repository_debs, :class_name => "Katello::RepositoryDeb", :dependent => :destroy, :inverse_of => :deb
    has_many :repositories, :through => :repository_debs, :class_name => "Katello::Repository"
    has_many :content_facet_applicable_debs, :class_name => "Katello::ContentFacetApplicableDeb",
             :dependent => :destroy, :inverse_of => :deb
    has_many :content_facets, :through => :content_facet_applicable_debs, :class_name => "Katello::Host::ContentFacet"

    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :architecture, :complete_value => true
    scoped_search :on => :filename, :complete_value => true
    scoped_search :on => :checksum

    def self.default_sort
      order(:name).order(:version).order(:architecture)
    end

    def self.repository_association_class
      RepositoryDeb
    end

    def self.content_facet_association_class
      ContentFacetApplicableDeb
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

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end

    # the format apt needs to identify the packet with version and architecture
    def nav
      "#{self.name}:#{self.architecture}=#{self.version}"
    end

    # the more natural format ;-)
    def nva
      "#{self.name}_#{self.version}_#{self.architecture}"
    end

    def self.split_nav(value)
      v = /^(?<name>[^:\s]+)(:(?<architecture>[^=\s]*))?(=(?<version>.*))?$/.match(value)&.named_captures
      if v
        [ v['name'], v['architecture'], v['version'] ]
      end
    end

    def hosts_applicable(org_id = nil)
      if org_id.present?
        self.content_facets.joins(:host).where("#{::Host.table_name}.organization_id" => org_id)
      else
        self.content_facets.joins(:host)
      end
    end

    def hosts_available(org_id = nil)
      self.hosts_applicable(org_id).joins("INNER JOIN #{Katello::RepositoryDeb.table_name} on \
        #{Katello::RepositoryDeb.table_name}.deb_id = #{self.id}").joins(:content_facet_repositories).
        where("#{Katello::ContentFacetRepository.table_name}.repository_id = #{Katello::RepositoryDeb.table_name}.repository_id").uniq
    end

    def self.installable_for_hosts(hosts = nil)
      debs = Katello::Deb.joins(:repositories,
                                "INNER JOIN #{Katello::InstalledDeb.table_name} ON #{Katello::InstalledDeb.table_name}.name = #{self.table_name}.name",
                                "INNER JOIN #{Katello::HostInstalledDeb.table_name} ON #{Katello::HostInstalledDeb.table_name}.installed_deb_id = #{Katello::InstalledDeb.table_name}.id")
                               .where("deb_version_cmp(#{self.table_name}.version, #{Katello::InstalledDeb.table_name}.version) > 0")
      unless hosts.nil?
        facet_repos = Katello::ContentFacetRepository.joins(:content_facet => :host).select(:repository_id)
        hosts = ::Host.where(id: hosts) if hosts.is_a?(Array)
        facet_repos = facet_repos.merge(hosts).reorder(nil)

        debs = debs.where("#{Katello::HostInstalledDeb.table_name}.host_id": hosts.pluck(:id))
                   .where("#{Katello::RepositoryDeb.table_name}.repository_id" => facet_repos)
      end
      debs.distinct
    end

    def self.applicable_to_hosts(hosts)
      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts).distinct
    end

    # Return deb packages that are not installed on a host, but could be installed
    # the word 'installable' has a different meaning here than elsewhere
    def self.apt_installable_for_host(host)
      repos = host.content_facet.bound_repositories.pluck(:id)
      Katello::Deb.in_repositories(repos).where.not(name: host.installed_debs.pluck(:name)).order(:name)
    end

    def self.latest(_relation)
      fail 'NotImplemented'
    end
  end
end
