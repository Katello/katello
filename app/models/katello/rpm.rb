module Katello
  class Rpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = 'rpm'.freeze
    has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm",
             :dependent => :destroy, :inverse_of => :rpm
    has_many :content_facets, :through => :content_facet_applicable_rpms, :class_name => "Katello::Host::ContentFacet"
    has_many :module_stream_rpms, class_name: "Katello::ModuleStreamRpm", inverse_of: :rpm, dependent: :destroy
    has_many :module_streams, :through => :module_stream_rpms
    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true, :ext_method => :scoped_search_version
    scoped_search :on => :release, :complete_value => true, :ext_method => :scoped_search_release
    scoped_search :on => :arch, :complete_value => true
    scoped_search :on => :epoch, :complete_value => true
    scoped_search :on => :evr, :ext_method => :scoped_search_evr, :only_explicit => true
    scoped_search :on => :filename, :complete_value => true
    scoped_search :on => :sourcerpm, :complete_value => true
    scoped_search :on => :nvra, :complete_value => true
    scoped_search :on => :modular, :complete_value => true, :only_explicit => true
    scoped_search :on => :checksum

    scope :modular, -> { where(modular: true) }
    scope :non_modular, -> { where(modular: false) }

    def self.default_sort
      order(:name).order(:epoch).order(:version_sortable).order(:release_sortable)
    end

    def self.content_facet_association_class
      ContentFacetApplicableRpm
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

    def self.applicable_to_hosts(hosts)
      self.joins(:content_facets).
        where("#{Katello::Host::ContentFacet.table_name}.host_id" => hosts).distinct
    end

    # Return RPMs that are not installed on a host, but could be installed
    # the word 'installable' has a different meaning here than elsewhere
    def self.yum_installable_for_host(host)
      repos = host.content_facet.bound_repositories.pluck(:id)
      Katello::Rpm.in_repositories(repos).where.not(name: host.installed_packages.pluck(:name)).order(:name)
    end

    def self.latest(relation)
      # There are several different ways to implement this:

      # 1) Use a LEFT OUTER JOIN to join the query with itself on name=name,
      #    arch=arch, evr<evr, then select unmatched rows.
      #    In PostgreSQL 9.2 populated with real data, EXPLAIN shows
      #    cost=339901.07..381834.02 for the SQL generated by this when a
      #    package search is performed with a content_view_version_id filter.
      #    Unfortunately, this requires writing raw SQL for the JOIN and using
      #    to_sql, which may be somewhat brittle.  For example, be aware of
      #    quirks like https://github.com/rails/rails/issues/18379
      return relation.joins(
        "LEFT OUTER JOIN (#{relation.to_sql}) AS katello_rpms2 ON " \
        'katello_rpms.name = katello_rpms2.name AND katello_rpms.arch = katello_rpms2.arch AND ' \
        '(CAST(katello_rpms.epoch AS INT) < CAST(katello_rpms2.epoch AS INT) OR ' \
        ' (CAST(katello_rpms.epoch AS INT) = CAST(katello_rpms2.epoch AS INT) AND ' \
        '  (katello_rpms.version_sortable COLLATE "C" < katello_rpms2.version_sortable COLLATE "C" OR ' \
        '   (katello_rpms.version_sortable = katello_rpms2.version_sortable AND ' \
        '    katello_rpms.release_sortable COLLATE "C" < katello_rpms2.release_sortable COLLATE "C"))))'
      ).where('katello_rpms2.release_sortable IS NULL')

      # 2) Use GROUP BY with MAX() and several INNER JOINs to identify the
      #    latest evr, then INNER JOIN again to get complete rows.
      #    Like #1, this must also be written using raw SQL and to_sql.
      #    cost=677566.03..704889.89
      #max_epochs = relation.
      #  group(:name, :arch).
      #  select(:name, :arch, 'MAX(CAST(katello_rpms.epoch AS INT)) AS max_epoch')
      #max_versions = relation.
      #  joins(
      #    "INNER JOIN (#{max_epochs.to_sql}) katello_rpms2 ON " \
      #    'katello_rpms.name = katello_rpms2.name AND katello_rpms.arch = katello_rpms2.arch AND ' \
      #    'CAST(katello_rpms.epoch AS INT) = katello_rpms2.max_epoch'
      #  ).
      #  group(:name, :arch, :epoch).
      #  select(:name, :arch, :epoch, 'MAX(katello_rpms.version_sortable COLLATE "C") AS max_version')
      #max_releases = relation.
      #  joins(
      #    "INNER JOIN (#{max_versions.to_sql}) katello_rpms2 ON " \
      #    'katello_rpms.name = katello_rpms2.name AND katello_rpms.arch = katello_rpms2.arch AND ' \
      #    'CAST(katello_rpms.epoch AS INT) = CAST(katello_rpms2.epoch AS INT) AND ' \
      #    'katello_rpms.version_sortable = katello_rpms2.max_version'
      #  ).
      #  group(:name, :arch, :epoch, :version_sortable).
      #  select(:name, :arch, :epoch, :version_sortable, 'MAX(katello_rpms.release_sortable COLLATE "C") AS max_release')
      #return relation.
      #  joins(
      #    "INNER JOIN (#{max_releases.to_sql}) katello_rpms2 ON " \
      #    'katello_rpms.name = katello_rpms2.name AND katello_rpms.arch = katello_rpms2.arch AND ' \
      #    'CAST(katello_rpms.epoch AS INT) = CAST(katello_rpms2.epoch AS INT) AND ' \
      #    'katello_rpms.version_sortable = katello_rpms2.version_sortable AND ' \
      #    'katello_rpms.release_sortable = katello_rpms2.max_release'
      #  )

      # 3) Like #1, but use a Common Table Expression instead of a
      #    LEFT OUTER JOIN to join the query with itself.
      #    This seems to be faster than #1 in some cases and slower in others
      #    depending on optimizer behavior.
      #    For the same test case as used for #1, cost=404240.71..405796.40
      #    However, this is not supported in all versions of all databases
      #    (e.g. it only works in MySQL >=8.0).
      #    This can be written using either raw SQL or Arel.
      #
      # 3a) Raw SQL
      #cte_sql = relation.select('katello_rpms.*, CAST(katello_rpms.epoch AS INT) AS epoch_sortable').to_sql
      #return Rpm.where('katello_rpms.id IN (' \
      #  "WITH katello_rpms AS (#{cte_sql}) " \
      #  'SELECT katello_rpms.id from katello_rpms LEFT OUTER JOIN katello_rpms AS katello_rpms2 ON ' \
      #  'katello_rpms.name = katello_rpms2.name AND katello_rpms.arch = katello_rpms2.arch AND ' \
      #  '(katello_rpms.epoch_sortable < katello_rpms2.epoch_sortable OR ' \
      #  ' (katello_rpms.epoch_sortable = katello_rpms2.epoch_sortable AND ' \
      #  '  (katello_rpms.version_sortable COLLATE "C" < katello_rpms2.version_sortable COLLATE "C" OR ' \
      #  '   (katello_rpms.version_sortable = katello_rpms2.version_sortable AND ' \
      #  '    katello_rpms.release_sortable COLLATE "C" < katello_rpms2.release_sortable COLLATE "C")))) ' \
      #  'WHERE katello_rpms2.release_sortable IS NULL' \
      #')')
      #
      # 3b) Arel
      #     Unlike #1, #2, and #3a, this does not require raw SQL or to_sql.
      #     Unfortunately this doesn't work reliably in Rails 4.2 because
      #     relation.unscoped.where(relation.arel_table[:id].in(relation.arel))
      #     looses the prepared statement parameter values.  See:
      #     https://github.com/rails/rails/issues/13686
      ## Convert current query to Arel for use in a CTE
      #orig_query = relation.arel
      ## Add another column to the original query: CAST(epoch AS INT) AS epoch_sortable
      #orig_table = relation.arel_table
      #orig_query = orig_query.project(Arel::Nodes::NamedFunction.new('CAST', [orig_table[:epoch].as('INT')], 'epoch_sortable'))
      ## Create two names that will both refer to the existing query in the CTE
      #cte1 = Arel::Table.new(:katello_rpms)
      #cte2 = Arel::Table.new(:katello_rpms2)
      ## Create a new Arel query and use a CTE to JOIN the original query with
      ## itself and select the latest evr for each name/arch
      #new_query = cte1.project(cte1[:id]).with(Arel::Nodes::As.new(cte1, orig_query)).
      #  join(Arel::Nodes::As.new(cte1, cte2), Arel::Nodes::OuterJoin).on(
      #    cte1[:name].eq(cte2[:name]).and(cte1[:arch].eq(cte2[:arch])).and(
      #      cte1[:epoch_sortable].lt(cte2[:epoch_sortable]).or(
      #        cte1[:epoch_sortable].eq(cte2[:epoch_sortable]).and(
      #          Arel::Nodes::SqlLiteral.new('katello_rpms.version_sortable COLLATE "C"').lt(Arel::Nodes::SqlLiteral.new('katello_rpms2.version_sortable COLLATE "C"')).or(
      #            cte1[:version_sortable].eq(cte2[:version_sortable]).and(
      #              Arel::Nodes::SqlLiteral.new('katello_rpms.release_sortable COLLATE "C"').lt(Arel::Nodes::SqlLiteral.new('katello_rpms2.release_sortable COLLATE "C"'))
      #            )
      #          )
      #        )
      #      )
      #    )
      #  ).
      #  where(cte2[:release_sortable].eq(nil))
      ## Wrap the new Arel query in a new ActiveRecord::Relation
      #return relation.unscoped.where(orig_table[:id].in(new_query))
    end
  end
end
