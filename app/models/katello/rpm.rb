module Katello
  class Rpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::Rpm::CONTENT_TYPE

    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :destroy, :inverse_of => :rpm
    has_many :repositories, :through => :repository_rpms, :class_name => "Katello::Repository"

    has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm",
             :dependent => :destroy, :inverse_of => :rpm
    has_many :content_facets, :through => :content_facet_applicable_rpms, :class_name => "Katello::Host::ContentFacet"

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true, :ext_method => :scoped_search_version
    scoped_search :on => :release, :complete_value => true, :ext_method => :scoped_search_release
    scoped_search :on => :arch, :complete_value => true
    scoped_search :on => :epoch, :complete_value => true
    scoped_search :on => :evr, :ext_method => :scoped_search_evr, :only_explicit => true
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

    def self.scoped_search_version(_key, operator, value)
      self.scoped_search_sortable('version', operator, value)
    end

    def self.scoped_search_release(_key, operator, value)
      self.scoped_search_sortable('release', operator, value)
    end

    def self.scoped_search_sortable(column, operator, value)
      if ['>', '>=', '<', '<='].include?(operator)
        conditions = "#{self.table_name}.#{column}_sortable COLLATE \"C\" #{operator} ? COLLATE \"C\""
        parameter = Util::Package.sortable_version(value)
        return { :conditions => conditions, :parameter => [parameter] }
      end

      # Use the default behavior for all other operators.
      # Unfortunately there is no way to call the default behavior from here, so
      # we replicate the default behavior from sql_test() in
      # https://github.com/wvanbergen/scoped_search/blob/master/lib/scoped_search/query_builder.rb
      if ['LIKE', 'NOT LIKE'].include?(operator)
        conditions = "#{self.table_name}.#{column} #{operator} ?"
        parameter = (value !~ /^\%|\*/ && value !~ /\%|\*$/) ? "%#{value}%" : value.tr_s('%*', '%')
        return { :conditions => conditions, :parameter => [parameter] }
      elsif ['IN', 'NOT IN'].include?(operator)
        conditions = "#{self.table_name}.#{column} #{operator} (#{value.split(',').collect { '?' }.join(',')})"
        parameters = value.split(',').collect { |v| v.strip }
        return { :conditions => conditions, :parameter => parameters }
      else
        conditions = "#{self.table_name}.#{column} #{operator} ?"
        parameter = value
        return { :conditions => conditions, :parameter => [parameter] }
      end
    end

    def self.scoped_search_evr(_key, operator, value)
      if ['=', '<>'].include?(operator)
        return self.scoped_search_evr_equal(operator, value)
      elsif ['IN', 'NOT IN'].include?(operator)
        return self.scoped_search_evr_in(operator, value)
      elsif ['LIKE', 'NOT LIKE'].include?(operator)
        return self.scoped_search_evr_like(operator, value)
      elsif ['>', '>=', '<', '<='].include?(operator)
        return self.scoped_search_evr_compare(operator, value)
      else
        return {}
      end
    end

    def self.scoped_search_evr_equal(operator, value)
      joiner = (operator == '=' ? 'AND' : 'OR')
      evr = Util::Package.parse_evr(value)
      (e, v, r) = [evr[:epoch], evr[:version], evr[:release]]
      e = e.to_i # nil or blank becomes 0
      conditions = "CAST(#{self.table_name}.epoch AS INT) #{operator} ?"
      parameters = [e]
      unless v.nil? || v.blank?
        conditions += " #{joiner} #{self.table_name}.version #{operator} ?"
        parameters += [v]
      end
      unless r.nil? || r.blank?
        conditions += " #{joiner} #{self.table_name}.release #{operator} ?"
        parameters += [r]
      end
      return { :conditions => conditions, :parameter => parameters }
    end

    def self.scoped_search_evr_in(operator, value)
      op = (operator == 'IN' ? '=' : '<>')
      joiner1 = (operator == 'IN' ? 'AND' : 'OR')
      joiner2 = (operator == 'IN' ? 'OR' : 'AND')
      conditions = []
      parameters = []
      value.split(',').collect { |v| v.strip }.each do |val|
        evr = Util::Package.parse_evr(val)
        (e, v, r) = [evr[:epoch], evr[:version], evr[:release]]
        e = e.to_i # nil or blank becomes 0
        condition = "CAST(#{self.table_name}.epoch AS INT) #{op} ?"
        parameters += [e]
        unless v.nil? || v.blank?
          condition += " #{joiner1} #{self.table_name}.version #{op} ?"
          parameters += [v]
        end
        unless r.nil? || r.blank?
          condition += " #{joiner1} #{self.table_name}.release #{op} ?"
          parameters += [r]
        end
        conditions += ["(#{condition})"]
      end
      return { :conditions => conditions.join(" #{joiner2} "), :parameter => parameters }
    end

    def self.scoped_search_evr_like(operator, value)
      val = (value !~ /^\%|\*/ && value !~ /\%|\*$/) ? "%#{value}%" : value.tr_s('%*', '%')
      evr = Util::Package.parse_evr(val)
      (e, v, r) = [evr[:epoch], evr[:version], evr[:release]]
      conditions = []
      parameters = []
      unless e.nil? || e.blank?
        conditions += ["CAST(#{self.table_name}.epoch AS VARCHAR(10)) #{operator} ?"]
        parameters += [e]
      end
      unless v.nil? || v.blank?
        conditions += ["#{self.table_name}.version #{operator} ?"]
        parameters += [v]
      end
      unless r.nil? || r.blank?
        conditions += ["#{self.table_name}.release #{operator} ?"]
        parameters += [r]
      end
      return {} if conditions.empty?
      joiner = (operator == 'LIKE' ? 'AND' : 'OR')
      return { :conditions => conditions.join(" #{joiner} "), :parameter => parameters }
    end

    def self.scoped_search_evr_compare(operator, value)
      evr = Util::Package.parse_evr(value)
      (e, v, r) = [evr[:epoch], evr[:version], evr[:release]]
      e = e.to_i # nil or blank becomes 0
      conditions = ''
      if v.nil? || v.blank?
        conditions = "CAST(#{self.table_name}.epoch AS INT) #{operator} ?"
        parameters = [e]
      else
        sv = Util::Package.sortable_version(v)
        if r.nil? || r.blank?
          conditions = "#{self.table_name}.version_sortable COLLATE \"C\" #{operator} ? COLLATE \"C\""
          parameters = [sv]
        else
          conditions =
            "#{self.table_name}.version_sortable COLLATE \"C\" #{operator[0]} ? COLLATE \"C\" OR " \
            "(#{self.table_name}.version_sortable = ? AND " \
             "#{self.table_name}.release_sortable COLLATE \"C\" #{operator} ? COLLATE \"C\")"
          sv = Util::Package.sortable_version(v)
          parameters = [sv, sv, Util::Package.sortable_version(r)]
        end
        conditions = "CAST(#{self.table_name}.epoch AS INT) #{operator[0]} ? OR (CAST(#{self.table_name}.epoch AS INT) = ? AND (#{conditions}))"
        parameters = [e, e] + parameters
      end
      return { :conditions => conditions, :parameter => parameters }
    end

    def self.search_version_range(min = nil, max = nil)
      query = self.all
      query = Katello::Util::PackageFilter.new(query, min, Katello::Util::PackageFilter::GREATER_THAN).results if min.present?
      query = Katello::Util::PackageFilter.new(query, max, Katello::Util::PackageFilter::LESS_THAN).results if max.present?
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
      self.in_repositories(repos).count
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
      hosts = ::Host.where(:id => hosts) if hosts && hosts.is_a?(Array)

      query = Katello::Rpm.joins(:content_facet_applicable_rpms).
        joins("INNER JOIN #{Katello::ContentFacetRepository.table_name} on \
        #{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::ContentFacetApplicableRpm.table_name}.content_facet_id").
        joins("INNER JOIN #{Katello::RepositoryRpm.table_name} AS host_repo_rpm ON \
          host_repo_rpm.rpm_id = #{Katello::Rpm.table_name}.id AND \
          #{Katello::ContentFacetRepository.table_name}.repository_id = host_repo_rpm.repository_id")

      if hosts
        query = query.where("#{Katello::ContentFacetRepository.table_name}.content_facet_id" => hosts.joins(:content_facet)
                                .select("#{Katello::Host::ContentFacet.table_name}.id"))
      else
        query = query.joins(:content_facet_applicable_rpms)
      end

      query
    end

    def self.applicable_to_hosts(hosts)
      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts).distinct
    end
  end
end
