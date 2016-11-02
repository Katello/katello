module Katello
  module Util
    class DockerManifestClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.docker
      end

      def collect_clauses(repo, filters)
        [ContentViewDockerFilter].collect do |filter_class|
          content_type_filters = filters.where(:type => filter_class)
          make_manifest_clauses(repo, content_type_filters) unless content_type_filters.empty?
        end
      end

      def whitelist_non_matcher_clause
        {"name" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"name" => {"$exists" => true}}
      end

      def make_manifest_clauses(repo, filters)
        pulp_content_clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        unless pulp_content_clauses.empty?
          manifest_clauses_from_content(pulp_content_clauses)
        end
      end

      def manifest_clauses_from_content(pulp_content_clauses)
        {"$or" => pulp_content_clauses}
      end
    end
  end
end
