module Katello
  module Util
    class ErratumClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.yum_errata_only
      end

      def whitelist_non_matcher_clause
        {"id" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"id" => {"$exists" => true}}
      end

      def collect_clauses(repo, filters)
        return if filters.blank?

        pulp_content_clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        unless pulp_content_clauses.empty?
          [errata_clauses_from_content(pulp_content_clauses)]
        end
      end

      # input ->  [{"type"=>{"$in"=>[:bugfix, :security]}}] <- Errata Pulp Clauses
      # output -> {"filename" => {"$in" => {"foo.el6.noarch", "..."}}} <- Packages belonging to those errata
      def errata_clauses_from_content(pulp_content_clauses)
        errata_ids = Katello::Erratum.list_errata_id_by_clauses(@repo, pulp_content_clauses)
        {'id' => {"$in" => errata_ids}} unless errata_ids.empty?
      end
    end
  end
end
