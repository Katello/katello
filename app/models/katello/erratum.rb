module Katello
  class Erratum < Katello::Model
    include Concerns::PulpDatabaseUnit

    SECURITY = "security".freeze
    BUGZILLA = "bugfix".freeze
    ENHANCEMENT = "enhancement".freeze

    TYPES = [SECURITY, BUGZILLA, ENHANCEMENT].freeze
    CONTENT_TYPE = Pulp::Erratum::CONTENT_TYPE

    has_many :content_facets, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet
    has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet
    has_many :content_facets_applicable, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet

    has_many :repositories, :through => :repository_errata, :class_name => "Katello::Repository"
    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :destroy, :inverse_of => :erratum

    has_many :bugzillas, :class_name => "Katello::ErratumBugzilla", :dependent => :destroy, :inverse_of => :erratum
    has_many :cves, :class_name => "Katello::ErratumCve", :dependent => :destroy, :inverse_of => :erratum
    has_many :packages, :class_name => "Katello::ErratumPackage", :dependent => :destroy, :inverse_of => :erratum

    scoped_search :on => :errata_id, :rename => :id, :complete_value => true, :only_explicit => true
    scoped_search :on => :title, :only_explicit => true
    scoped_search :on => :severity, :complete_value => true
    scoped_search :on => :errata_type, :rename => :type, :complete_value => true
    scoped_search :on => :issued, :complete_value => true
    scoped_search :on => :updated, :complete_value => true
    scoped_search :on => :reboot_suggested, :complete_value => true
    scoped_search :relation => :cves, :on => :cve_id, :rename => :cve
    scoped_search :relation => :bugzillas, :on => :bug_id, :rename => :bug
    scoped_search :relation => :packages, :on => :nvrea, :rename => :package, :complete_value => true
    scoped_search :relation => :packages, :on => :name, :rename => :package_name, :complete_value => true

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

    def self.applicable_to_hosts(hosts)
      # Note: ContentFacetErrata actually holds the "Applicable Errata" to that host
      # It is not the errata "belonging" to the host. Its rather the errata that is "applicable"
      # which is calculated elsewhere.

      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts.pluck(:id))
    end

    def self.applicable_to_hosts_dashboard(hosts)
      applicable_to_hosts(hosts).
        select("DISTINCT ON (#{self.table_name}.updated, #{self.table_name}.id) #{self.table_name}.*").
        order("#{self.table_name}.updated desc").limit(6)
    end

    def <=>(other)
      return self.errata_id <=> other.errata_id
    end

    def self.with_identifiers(ids)
      ids = [ids] unless ids.is_a?(Array)
      ids.map!(&:to_s)
      id_integers = ids.map { |string| Integer(string) rescue -1 }
      where("#{self.table_name}.id in (?) or #{self.table_name}.uuid in (?) or #{self.table_name}.errata_id in (?)", id_integers, ids, ids)
    end

    def hosts_applicable(org_id = nil)
      if org_id.present?
        self.content_facets_applicable.joins(:host).where("#{::Host.table_name}.organization_id" => org_id)
      else
        self.content_facets_applicable.joins(:host)
      end
    end

    def hosts_available(org_id = nil)
      self.hosts_applicable(org_id).joins("INNER JOIN #{Katello::RepositoryErratum.table_name} on \
        #{Katello::RepositoryErratum.table_name}.erratum_id = #{self.id}").joins(:content_facet_repositories).
        where("#{Katello::ContentFacetRepository.table_name}.repository_id = #{Katello::RepositoryErratum.table_name}.repository_id").uniq
    end

    def self.installable_for_hosts(hosts = nil)
      self.where(:id => ids_installable_for_hosts(hosts))
    end

    def self.ids_installable_for_hosts(hosts = nil)
      hosts = ::Host.where(:id => hosts) if hosts && hosts.is_a?(Array)

      # Main goal of this query
      # 1) Get me the applicable errata for these set of hosts
      # 2) Now further prune this list. Only include errata from repos that have been "enabled" on those hosts.
      #    In other words, prune the list to only include the errate in the "bound" repositories signified by
      #    the inner join between ContentFacetRepository and RepositoryErratum
      query = self.joins(:content_facet_errata).
        joins("INNER JOIN #{Katello::ContentFacetRepository.table_name} on \
        #{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::ContentFacetErratum.table_name}.content_facet_id").
        joins("INNER JOIN #{Katello::RepositoryErratum.table_name} AS host_repo_errata ON \
          host_repo_errata.erratum_id = #{Katello::Erratum.table_name}.id AND \
          #{Katello::ContentFacetRepository.table_name}.repository_id = host_repo_errata.repository_id")

      if hosts
        query = query.where("#{Katello::ContentFacetRepository.table_name}.content_facet_id" => hosts.joins(:content_facet)
                                .select("#{Katello::Host::ContentFacet.table_name}.id"))
      else
        query = query.joins(:content_facet_errata)
      end

      query
    end

    def update_from_json(json)
      keys = %w(title id severity issued type description reboot_suggested solution updated summary)
      custom_json = json.slice(*keys)

      if self.updated.blank? || (custom_json['updated'].to_datetime != self.updated.to_datetime)
        custom_json['errata_id'] = custom_json.delete('id')
        custom_json['errata_type'] = custom_json.delete('type')
        custom_json['updated'] = custom_json['updated'].blank? ? custom_json['issued'] : custom_json['updated']
        self.update_attributes!(custom_json)

        unless json['references'].blank?
          update_bugzillas(json['references'].select { |r| r['type'] == 'bugzilla' })
          update_cves(json['references'].select { |r| r['type'] == 'cve' })
        end
      end
      update_packages(json['pkglist']) unless json['pkglist'].blank?
    end

    def self.list_filenames_by_clauses(repo, clauses)
      errata = Katello.pulp_server.extensions.errata.search(Katello::Erratum::CONTENT_TYPE, :filters => clauses)
      Katello::ErratumPackage.joins(:erratum => :repository_errata).
          where("#{RepositoryErratum.table_name}.repository_id" => repo.id,
                "#{Erratum.table_name}.uuid" => errata.map { |e| e['_id'] }).pluck(:filename)
    end

    private

    def run_until(needed_function, action_function)
      needed = needed_function.call
      retries = needed.length
      until needed.empty? || retries == 0
        begin
          action_function.call(needed)
        rescue ActiveRecord::RecordNotUnique
          self.reload
        end
        needed = needed_function.call
        retries -= 1
      end
      fail _('Failed indexing errata, maximum retries encountered') if retries == 0 && needed.any?
    end

    def update_bugzillas(json)
      needed_function = lambda do
        existing_names = bugzillas.pluck(:bug_id)
        json.select { |bz| !existing_names.include?(bz['id']) }
      end
      action_function = lambda do |needed|
        bugzillas.create!(needed.map { |bug| {:bug_id => bug['id'], :href => bug['href']} })
      end
      run_until(needed_function, action_function)
    end

    def update_cves(json)
      needed_function = lambda do
        existing_names = cves.pluck(:cve_id)
        json.select { |cve| !existing_names.include?(cve['id']) }
      end
      action_function = lambda do |needed|
        cves.create!(needed.map { |cve| {:cve_id => cve['id'], :href => cve['href']} })
      end
      run_until(needed_function, action_function)
    end

    def update_packages(json)
      needed_function = lambda do
        package_hashes = json.map { |list| list['packages'] }.flatten
        package_attributes = package_hashes.map do |hash|
          nvrea = "#{hash['name']}-#{hash['version']}-#{hash['release']}.#{hash['arch']}"
          {'name' => hash['name'], 'nvrea' => nvrea, 'filename' => hash['filename']}
        end
        existing_nvreas = self.packages.pluck(:nvrea)
        package_attributes.delete_if { |pkg| existing_nvreas.include?(pkg['nvrea']) }
        package_attributes.uniq { |pkg| pkg['nvrea'] }
      end
      action_function = lambda do |needed|
        self.packages.create!(needed)
      end
      run_until(needed_function, action_function)
    end
  end
end
