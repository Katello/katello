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
        match = case evr
                when /\A(\d+):(.*)-(.*)\z/
                  evr.match(/\A(?<epoch>\d+):(?<version>.*)-(?<release>.*)\z/)
                when /\A(\d+):(.*)\z/
                  evr.match(/\A(?<epoch>\d+):(?<version>.*)\z/)
                when /\A(.*)-(.*)\z/
                  evr.match(/\A(?<version>.*)-(?<release>.*)\z/)
                else
                  evr.match(/\A(?<version>.*)\z/)
                end
        self.version = Package.sortable_version(match[:version])
        self.epoch = match[:epoch] rescue nil
        self.release = (match[:release] rescue nil) ? Package.sortable_version(match[:release]) : nil
      end

      def results
        version_clause = "#{convert(:version_sortable)} #{operator} #{convert(':version')}"
        version_clause = add_release_clause(version_clause) unless release.blank?
        version_clause = add_epoch_clause(version_clause) unless epoch.blank?

        self.relation.where(version_clause, :version => version, :release => release, :epoch => epoch)
      end

      def add_release_clause(version_clause)
        clause = "(#{convert(:version_sortable)} = #{convert(':version')} AND #{convert(:release_sortable)} #{operator} #{convert(':release')})"

        # if we're using EQUAL, match: version = X AND release = Y
        # else if we're using something like greater than, we need:
        #   (version > X) OR (version = X AND release > Y)
        if operator == EQUAL
          clause
        else
          "#{version_clause} OR #{clause}"
        end
      end

      def add_epoch_clause(version_clause)
        if operator == EQUAL
          clause = "(epoch = :epoch AND (%s))"
        else
          clause = "epoch #{operator} :epoch OR (epoch = :epoch AND (%s))"
        end
        clause % version_clause
      end

      def convert(name = '?')
        "convert_to(#{name}, 'SQL_ASCII')"
      end
    end
  end
end
