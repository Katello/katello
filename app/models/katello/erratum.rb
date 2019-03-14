module Katello
  class Erratum < Katello::Model
    include Concerns::PulpDatabaseUnit

    SECURITY = ["security"].freeze
    BUGZILLA = ["bugfix", "recommended"].freeze
    ENHANCEMENT = ["enhancement", "optional"].freeze

    TYPES = [SECURITY, BUGZILLA, ENHANCEMENT].flatten.freeze
    CONTENT_TYPE = "erratum".freeze

    has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet
    has_many :content_facets, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet
    has_many :content_facets_applicable, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet

    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :destroy, :inverse_of => :erratum
    has_many :repositories, :through => :repository_errata, :class_name => "Katello::Repository"

    has_many :bugzillas, :class_name => "Katello::ErratumBugzilla", :dependent => :destroy, :inverse_of => :erratum
    has_many :cves, :class_name => "Katello::ErratumCve", :dependent => :destroy, :inverse_of => :erratum
    has_many :packages, :class_name => "Katello::ErratumPackage", :dependent => :destroy, :inverse_of => :erratum

    scoped_search :on => :errata_id, :only_explicit => true
    scoped_search :on => :errata_id, :rename => :id, :complete_value => true, :only_explicit => true
    scoped_search :on => :title, :only_explicit => true
    scoped_search :on => :severity, :complete_value => true
    scoped_search :on => :errata_type, :only_explicit => true
    scoped_search :on => :errata_type, :rename => :type, :complete_value => true
    scoped_search :on => :issued, :complete_value => true
    scoped_search :on => :updated, :complete_value => true
    scoped_search :on => :reboot_suggested, :complete_value => true
    scoped_search :relation => :cves, :on => :cve_id, :rename => :cve
    scoped_search :relation => :bugzillas, :on => :bug_id, :rename => :bug
    scoped_search :relation => :packages, :on => :nvrea, :rename => :package, :complete_value => true, :only_explicit => true
    scoped_search :relation => :packages, :on => :name, :rename => :package_name, :complete_value => true, :only_explicit => true

    before_save lambda { |erratum| erratum.title = erratum.title.truncate(255) unless erratum.title.blank? }

    def self.of_type(type)
      where(:errata_type => type)
    end

    scope :security, -> { of_type(Erratum::SECURITY) }
    scope :bugfix, -> { of_type(Erratum::BUGZILLA) }
    scope :enhancement, -> { of_type(Erratum::ENHANCEMENT) }

    def self.repository_association_class
      RepositoryErratum
    end

    def self.content_facet_association_class
      ContentFacetErratum
    end

    def self.applicable_to_hosts(hosts)
      # Note: ContentFacetErrata actually holds the "Applicable Errata" to that host
      # It is not the errata "belonging" to the host. Its rather the errata that is "applicable"
      # which is calculated elsewhere.

      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts.select(:id))
    end

    def self.applicable_to_hosts_dashboard(hosts)
      Erratum.where(:id => applicable_to_hosts(hosts)).
        order("#{self.table_name}.updated desc").limit(6)
    end

    def <=>(other)
      return self.errata_id <=> other.errata_id
    end

    def self.with_identifiers(ids)
      ids = [ids] unless ids.is_a?(Array)
      ids.map!(&:to_s)
      id_integers = ids.map { |string| Integer(string) rescue -1 }
      where("#{self.table_name}.id in (?) or #{self.table_name}.pulp_id in (?) or #{self.table_name}.errata_id in (?)", id_integers, ids, ids)
    end

    def hosts_applicable(org_id = nil)
      if org_id.present?
        self.content_facets_applicable.joins(:host).where("#{::Host.table_name}.organization_id" => org_id)
      else
        self.content_facets_applicable.joins(:host)
      end
    end

    def hosts_available(org_id = nil)
      self.hosts_applicable(org_id).distinct.joins("INNER JOIN #{Katello::RepositoryErratum.table_name} on \
        #{Katello::RepositoryErratum.table_name}.erratum_id = #{self.id}").joins(:content_facet_repositories).
        where("#{Katello::ContentFacetRepository.table_name}.repository_id = #{Katello::RepositoryErratum.table_name}.repository_id")
    end

    def self.installable_for_hosts(hosts = nil)
      ApplicableContentHelper.new(Erratum).installable_for_hosts(hosts)
    end

    def self.ids_installable_for_hosts(hosts = nil)
      installable_for_hosts(hosts).select(:id)
    end

    def self.list_filenames_by_clauses(repo, clauses)
      query_clauses = clauses.map do |clause|
        "(#{clause.to_sql})"
      end
      statement = query_clauses.join(" OR ")

      Katello::ErratumPackage.joins(:erratum => :repository_errata).
          where("#{RepositoryErratum.table_name}.repository_id" => repo.id).
          where(statement).pluck(:filename)
    end

    def module_streams
      # return something like
      # {module_stream => [packages]}
      module_stream_rpms = {}
      packages.each do |pack|
        pack.module_streams.each do |mod|
          module_stream_rpms[mod.module_spec_hash] ||= []
          module_stream_rpms[mod.module_spec_hash] << pack.nvrea unless module_stream_rpms[mod.module_spec_hash].include?(pack.nvrea)
        end
      end
      module_stream_rpms.map do |module_hash, nvreas|
        module_hash.merge(:packages => nvreas)
      end
    end

    def module_stream_objects
      streams = packages.map do |pack|
        pack.module_streams
      end
      return streams.flatten.uniq
    end

    class Jail < ::Safemode::Jail
      allow :errata_id, :errata_type, :issued, :created_at, :severity, :package_names, :cves, :reboot_suggested
    end
  end
end
