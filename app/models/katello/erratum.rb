module Katello
  class Erratum < Katello::Model
    include Concerns::PulpDatabaseUnit
    include Concerns::HostCounts

    SECURITY = ["security"].freeze
    BUGZILLA = ["bugfix", "recommended"].freeze
    ENHANCEMENT = ["enhancement", "optional"].freeze
    TYPES = [SECURITY, BUGZILLA, ENHANCEMENT].flatten.freeze

    NONE = "None".freeze
    LOW = "Low".freeze
    MODERATE = "Moderate".freeze
    IMPORTANT = "Important".freeze
    CRITICAL = "Critical".freeze
    SEVERITIES = [NONE, LOW, MODERATE, IMPORTANT, CRITICAL].freeze

    CONTENT_TYPE = "erratum".freeze
    BACKEND_IDENTIFIER_FIELD = "erratum_pulp3_href".freeze
    PRN_IDENTIFIER_FIELD = "erratum_prn".freeze

    has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet
    has_many :content_facets, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet
    has_many :content_facets_applicable, :through => :content_facet_errata, :class_name => "Katello::Host::ContentFacet", :source => :content_facet
    has_many :bugzillas, :class_name => "Katello::ErratumBugzilla", :dependent => :destroy, :inverse_of => :erratum
    has_many :cves, :class_name => "Katello::ErratumCve", :dependent => :destroy, :inverse_of => :erratum
    has_many :packages, :class_name => "Katello::ErratumPackage", :dependent => :destroy, :inverse_of => :erratum

    scoped_search :on => :id, :rename => :db_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :errata_id, :complete_value => true, :only_explicit => true
    scoped_search :on => :errata_id, :rename => :id, :complete_value => true, :only_explicit => true
    scoped_search :on => :title
    scoped_search :on => :title, :rename => :synopsis, :complete_value => true, :only_explicit => true
    scoped_search :on => :severity, :complete_value => true
    scoped_search :on => :errata_type, :only_explicit => true
    scoped_search :on => :errata_type,
                  :rename => :type,
                  :operators => ['=', '!='],
                  :complete_value => {
                    'security' => 'security',
                    'bugfix' => 'bugfix',
                    'enhancement' => 'enhancement',
                    'other' => 'other',
                  },
                  :ext_method => :filter_errata_type
    scoped_search :on => :issued, :complete_value => true
    scoped_search :on => :updated, :complete_value => true
    scoped_search :on => :reboot_suggested, :complete_value => true
    scoped_search :relation => :cves, :on => :cve_id, :rename => :cve, :only_explicit => true
    scoped_search :relation => :bugzillas, :on => :bug_id, :rename => :bug, :only_explicit => true
    scoped_search :relation => :packages, :on => :nvrea, :rename => :package, :complete_value => true, :only_explicit => true
    scoped_search :relation => :packages, :on => :name, :rename => :package_name, :complete_value => true, :only_explicit => true

    scoped_search :on => :modular,
                  :only_explicit => true,
                  :ext_method => :find_by_modular,
                  :complete_value => {:true => 0, :false => 1},
                  :special_values => ['true', 'false'],
                  :validator => ->(value) { ['true', 'false'].include?(value.downcase) },
                  :operators => ["="]

    # Bare identifiers are rewritten to their indexed fields; free text stays on title.
    class << self
      alias_method :search_for_without_identifiers, :search_for
      private :search_for_without_identifiers

      def search_for(query = '', options = {})
        search_for_without_identifiers(identifier_query(query.to_s), options)
      end

      private

      def identifier_query(search)
        tokens = search.split(/(\s+|[()])/)
        rewritten = tokens.each_with_index.map do |token, index|
          next token if token.strip.empty? || token.match?(/\A[()]\z/)
          next token if explicit_field?(tokens, index) || explicit_value?(tokens, index)

          identifier_term(token)
        end
        rewritten.join
      end

      def explicit_field?(tokens, index)
        following = tokens[(index + 1)..].find { |token| !token.strip.empty? }
        following&.match?(/\A(=|~|!=|!~|<>|in\z)/i)
      end

      def explicit_value?(tokens, index)
        previous = tokens[0...index].reverse.find { |token| !token.strip.empty? }
        return true if previous&.match?(/[=~<>!]\z/)
        return false unless previous == "("

        field = tokens[0...index].reverse.reject { |token| token.strip.empty? }[1]
        field&.match?(/\Ain\z/i)
      end

      def identifier_term(token)
        prefix = token[/\A[-!]/] || ''
        body = prefix.empty? ? token : token[1..]
        quoted = body.match(/\A"(.*)"\z/)
        value = quoted ? quoted[1] : body
        bare = quoted ? %("#{value}") : value

        case value
        when /\ACVE(-|\d|$)/i
          "#{prefix}(cve ~ #{value} or #{bare})"
        when /\A\d{4,}\z/
          "#{prefix}(cve ~ #{value} or bug ~ #{value} or #{bare})"
        else
          token
        end
      end
    end

    def self.of_type(type, include_other = false)
      if include_other
        where.not(
          :errata_type => [Erratum::SECURITY, Erratum::BUGZILLA, Erratum::ENHANCEMENT].flatten
          ).or(where(:errata_type => type))
      else
        where(:errata_type => type)
      end
    end

    def self.filter_errata_type(_key, operator, value)
      if value.downcase == "other"
        if ['!=', '<>'].include?(operator)
          { conditions: sanitize_sql_for_conditions(["errata_type IN (?)", TYPES]) }
        else
          { conditions: sanitize_sql_for_conditions(["errata_type NOT IN (?)", TYPES]) }
        end
      else
        if ['!=', '<>'].include?(operator)
          { conditions: sanitize_sql_for_conditions(["errata_type != ?", value]) }
        else
          { conditions: sanitize_sql_for_conditions(["errata_type = ?", value]) }
        end
      end
    end

    scope :security, -> { of_type(Erratum::SECURITY) }
    scope :bugfix, -> { of_type(Erratum::BUGZILLA) }
    scope :enhancement, -> { of_type(Erratum::ENHANCEMENT) }
    scope :modular, -> { where(:id => joins(:packages => :module_stream_errata_packages)) }
    scope :non_modular, -> { where.not(:id => modular) }

    def self.content_facet_association_class
      ContentFacetErratum
    end

    def self.backend_identifier_field
      SmartProxy.pulp_primary!.content_service(CONTENT_TYPE).backend_unit_identifier ? BACKEND_IDENTIFIER_FIELD.to_sym : nil
    end

    def self.applicable_to_hosts(hosts)
      # NOTE: ContentFacetErrata actually holds the "Applicable Errata" to that host
      # It is not the errata "belonging" to the host. Its rather the errata that is "applicable"
      # which is calculated elsewhere.

      self.group(:id).distinct.joins(:content_facets).
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

    def self.ids_installable_for_hosts(hosts = nil)
      installable_for_hosts(hosts).select(:id)
    end

    def self.list_filenames_by_clauses(repo, clauses, additional_included_errata)
      query_clauses = clauses.map do |clause|
        "(#{clause.to_sql})"
      end
      statement = query_clauses.join(" AND ")

      Katello::ErratumPackage.joins(:erratum => :repository_errata).
        where("#{RepositoryErratum.table_name}.repository_id" => repo.id).where(statement).pluck(:filename) -
        Katello::ErratumPackage.joins(:erratum => :repository_errata).where("#{RepositoryErratum.table_name}.repository_id" => repo.id).
          where("#{Erratum.table_name}.errata_id" => additional_included_errata.pluck(:errata_id)).pluck(:filename)
    end

    def self.list_modular_streams_by_clauses(repo, clauses, additional_included_errata)
      query_clauses = clauses.map do |clause|
        "(#{clause.to_sql})"
      end
      statement = query_clauses.join(" AND ")
      ModuleStream.where(:id => ModuleStreamErratumPackage.joins(:erratum_package => {:erratum => :repository_errata}).
          where("#{RepositoryErratum.table_name}.repository_id" => repo.id).
          where(statement).select("#{ModuleStreamErratumPackage.table_name}.module_stream_id")).
        joins(:repository_module_streams).
        where("#{RepositoryModuleStream.table_name}.repository_id" => repo.id) -
      ModuleStream.where(:id => ModuleStreamErratumPackage.joins(:erratum_package => {:erratum => :repository_errata}).
          where("#{RepositoryErratum.table_name}.repository_id" => repo.id).
          where(statement).where("#{Erratum.table_name}.errata_id" => additional_included_errata.pluck(:errata_id)).select("#{ModuleStreamErratumPackage.table_name}.module_stream_id")).
        joins(:repository_module_streams).
        where("#{RepositoryModuleStream.table_name}.repository_id" => repo.id)
    end

    def module_streams
      self.class.module_streams_by_erratum([id])[id] || []
    end

    def package_nvreas
      self.class.package_nvreas_by_erratum([id])[id] || []
    end

    def self.package_nvreas_by_erratum(erratum_ids)
      return {} if erratum_ids.empty?

      Katello::Util::IdBatches.slices(erratum_ids).each_with_object({}) do |ids, nvreas|
        ErratumPackage.where(:erratum_id => ids).non_module_stream_packages.
          pluck(:erratum_id, :nvrea).
          each { |erratum_id, nvrea| (nvreas[erratum_id] ||= []) << nvrea }
      end
    end

    def self.module_streams_by_erratum(erratum_ids)
      return {} if erratum_ids.empty?

      by_erratum = Katello::Util::IdBatches.slices(erratum_ids).each_with_object({}) do |ids, pairs|
        ModuleStream.
          joins(:module_stream_errata_packages => :erratum_package).
          where(:katello_erratum_packages => { :erratum_id => ids }).
          select("#{ModuleStream.table_name}.*",
                 "#{ErratumPackage.table_name}.erratum_id AS page_erratum_id",
                 "#{ErratumPackage.table_name}.nvrea AS page_nvrea").
          each { |stream| (pairs[stream[:page_erratum_id]] ||= []) << [stream.module_spec_hash, stream[:page_nvrea]] }
      end
      by_erratum.transform_values { |pairs| build_module_stream_specs(pairs) }
    end

    def self.build_module_stream_specs(pairs)
      specs = pairs.each_with_object({}) do |(module_hash, nvrea), grouped|
        (grouped[module_hash] ||= {})[nvrea] = true
      end
      specs.map { |module_hash, nvreas| module_hash.merge(:packages => nvreas.keys) }
    end

    def module_stream_specs
      packages.collect { |package| package.module_streams.map(&:module_spec) }.flatten.uniq
    end

    def module_stream_objects
      streams = packages.map do |pack|
        pack.module_streams
      end
      return streams.flatten.uniq
    end

    def self.find_by_modular(_key, operator, value)
      conditions = ""
      if operator == '='
        query = (value.downcase == "true") ? modular : non_modular
        conditions = "#{table_name}.id in (#{query.select(:id).to_sql})"
      else
        #failure condition. No such value so must return 0
        conditions = "1=0"
      end
      { :conditions => conditions }
    end

    def content_view_filters
      Katello::ContentViewErratumFilterRule.where(errata_id: self.errata_id).eager_load(:filter).map(&:filter)
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Erratum'
      refs 'Erratum'
      sections only: %w[all additional]
      property :errata_id, String, desc: 'Returns errata identifier, e.g. "RHSA-1999-1231"'
      property :errata_type, String, desc: 'Returns errata type, e.g. "security"'
      property :issued, Date, desc: 'Returns the date of issue for the errata'
      property :created_at, ActiveSupport::TimeWithZone, desc: 'Returns the time when the errata was created'
      property :severity, String, desc: 'Returns severity of the errata, e.g. "Critical"'
      property :package_names, array_of: String, desc: 'Returns names of packages the errata can be applied to'
      property :cves, array_of: 'ErratumCve', desc: 'Returns CVEs associated with the errata'
      property :reboot_suggested, one_of: [true, false], desc: 'Returns true if reboot is suggested after errata applying, false otherwise'
      property :title, String, desc: 'Returns the errata title, e.g. "Important: net-snmp security update"'
      property :summary, String, desc: 'Returns the errata summary, the length can very, it is usually in range of 60 to 1000 characters. It can include empty line characters.'
    end
    class Jail < ::Safemode::Jail
      allow :errata_id, :errata_type, :issued, :updated, :created_at, :severity, :package_names, :cves, :reboot_suggested, :title, :summary
    end
  end
end
