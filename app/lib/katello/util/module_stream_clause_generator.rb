module Katello
  module Util
    class ModuleStreamClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.module_stream.or(ContentViewFilter.errata)
      end

      def whitelist_non_matcher_clause
        {"_id" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"_id" => {"$exists" => true}}
      end

      def collect_clauses(repo, filters)
        [ContentViewErratumFilter, ContentViewModuleStreamFilter].collect do |filter_class|
          content_type_filters = filters.where(:type => filter_class.to_s)
          make_module_stream_clauses(repo, content_type_filters) unless content_type_filters.empty?
        end
      end

      def make_module_stream_clauses(repo, filters)
        content_type = filters.first.content_type
        pulp_content_clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        unless pulp_content_clauses.empty?
          module_stream_clauses_from_content(content_type, pulp_content_clauses)
        end
      end

      def module_stream_clauses_from_content(content_type, pulp_content_clauses)
        case content_type
        when ContentViewFilter::ERRATA
          clauses_for_errata(pulp_content_clauses)
        when ContentViewFilter::MODULE_STREAM
          clauses_for_module_streams(pulp_content_clauses)
        end
      end

      # input ->  [{"type"=>{"$in"=>[:bugfix, :security]}}] <- Errata Pulp Clauses
      # output -> {"_id" => {"$in" => [...]}} <- Module Streams belonging to those errata
      def clauses_for_errata(errata_clauses = [])
        module_streams = Katello::Erratum.list_modular_streams_by_clauses(@repo, errata_clauses)
        {'_id' => { "$in" => module_streams.pluck(:pulp_id)}} unless module_streams.empty?
      end

      def clauses_for_module_streams(module_stream_clauses = [])
        query_clauses = module_stream_clauses.map do |clause|
          "(#{clause.to_sql})"
        end
        return unless query_clauses.any?

        statement = query_clauses.join(" OR ")
        {'_id' => { "$in" => ModuleStream.where(statement).pluck(:pulp_id)}}
      end
    end
  end
end
