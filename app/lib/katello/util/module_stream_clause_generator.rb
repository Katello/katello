module Katello
  module Util
    class ModuleStreamClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.module_stream
      end

      def collect_clauses(repo, filters)
        module_streams = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        module_streams.compact!
        query_clauses = module_streams.map do |clause|
          "(#{clause.to_sql})"
        end
        return unless query_clauses.any?

        statement = query_clauses.join(" OR ")
        [{'_id' => { "$in" => ModuleStream.where(statement).pluck(:pulp_id)}}]
      end

      def whitelist_non_matcher_clause
        {"_id" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"_id" => {"$exists" => true}}
      end
    end
  end
end
