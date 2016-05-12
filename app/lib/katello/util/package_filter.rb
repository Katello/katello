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
        epoch_clause = "epoch #{operator} :epoch OR (epoch = :epoch AND (%s))"
        version_clause = "#{convert(:version_sortable)} #{operator} #{convert(':version')}"
        release_clause = "(#{convert(:version_sortable)} = #{convert(':version')} AND " \
            "#{convert(:release_sortable)} #{operator} #{convert(':release')})"

        version_clause = "#{version_clause} OR #{release_clause}" unless release.blank?
        version_clause = epoch_clause % version_clause unless epoch.blank?
        self.relation.where(version_clause, :version => version, :release => release, :epoch => epoch)
      end

      def convert(name = '?')
        "convert_to(#{name}, 'SQL_ASCII')"
      end
    end
  end
end
