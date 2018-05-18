module Katello
  module Util
    class PackageFilter
      LESS_THAN = "<".freeze
      GREATER_THAN = ">".freeze
      EQUAL = "=".freeze
      OPERATORS = [LESS_THAN, GREATER_THAN, EQUAL].freeze

      attr_accessor :operator, :version, :epoch, :release, :relation

      def initialize(relation, evr, operator = nil)
        extract_epoch_version_release(evr)
        self.operator = operator
        self.relation = relation
      end

      def extract_epoch_version_release(evr)
        parsed = Package.parse_evr(evr)
        self.epoch = parsed[:epoch].to_i # nil or blank becomes 0
        v = parsed[:version]
        self.version = (v.nil? || v.blank?) ? '' : Package.sortable_version(v)
        r = parsed[:release]
        self.release = (r.nil? || r.blank?) ? '' : Package.sortable_version(r)
      end

      def results
        if operator == EQUAL
          conditions = epoch_clause(operator)
          conditions += ' AND ' + version_clause(operator) unless version.blank?
          conditions += ' AND ' + release_clause(operator) unless release.blank?
        else
          conditions = ''
          unless version.blank?
            unless release.blank?
              conditions = " OR (#{version_clause('=')} AND #{release_clause(operator)})"
            end
            conditions = " OR (#{epoch_clause('=')} AND (#{version_clause(operator)}#{conditions}))"
          end
          conditions = "#{epoch_clause(operator)}#{conditions}"
        end

        self.relation.where(conditions, :version => version, :release => release, :epoch => epoch)
      end

      def epoch_clause(op)
        "CAST(epoch AS INT) #{op} :epoch"
      end

      def version_clause(op)
        if op == '='
          "version_sortable = :version"
        else
          "#{convert(:version_sortable)} #{op} #{convert(':version')}"
        end
      end

      def release_clause(op)
        if op == '='
          "release_sortable = :release"
        else
          "#{convert(:release_sortable)} #{op} #{convert(':release')}"
        end
      end

      def convert(name = '?')
        "#{name} COLLATE \"C\""
      end
    end
  end
end
