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
        clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        clauses.flatten!
        clauses.compact!
        module_stream_clauses_from_content(content_type, clauses) unless clauses.empty?
      end

      def module_stream_clauses_from_content(content_type, clauses)
        module_streams = []
        case content_type
        when ContentViewFilter::ERRATA
          module_streams = Katello::Erratum.list_modular_streams_by_clauses(@repo, clauses)
        when ContentViewFilter::MODULE_STREAM
          module_streams = ModuleStream.where(:id => clauses)
        end
        {'_id' => { "$in" => module_streams.pluck(:pulp_id)}} unless module_streams.empty?
      end
    end
  end
end
