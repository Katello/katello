module Katello
  module Util
    class DebClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.deb
      end

      def collect_clauses(repo, filters)
        [ContentViewDebFilter].collect do |filter_class|
          content_type_filters = filters.where(:type => filter_class.to_s)
          make_package_clauses(repo, content_type_filters) unless content_type_filters.empty?
        end
      end

      def whitelist_non_matcher_clause
        {"name" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"name" => {"$exists" => true}}
      end

      def make_package_clauses(repo, filters)
        pulp_content_clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        unless pulp_content_clauses.empty?
          package_clauses_from_content(pulp_content_clauses)
        end
      end

      def package_clauses_from_content(pulp_content_clauses)
        {"$or" => pulp_content_clauses}
      end
    end
  end
end
