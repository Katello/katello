module Katello
  module Util
    class PackageClauseGenerator
      include Util::FilterClauseGenerator

      protected

      def fetch_filters
        ContentViewFilter.yum
      end

      def collect_clauses(repo, filters)
        [ContentViewErratumFilter, ContentViewPackageGroupFilter, ContentViewPackageFilter].collect do |filter_class|
          content_type_filters = filters.where(:type => filter_class)
          make_package_clauses(repo, content_type_filters) unless content_type_filters.empty?
        end
      end

      def whitelist_non_matcher_clause
        {"filename" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"filename" => {"$exists" => true}}
      end

      def make_package_clauses(repo, filters)
        content_type = filters.first.content_type
        pulp_content_clauses = filters.collect do |filter|
          filter.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        unless pulp_content_clauses.empty?
          package_clauses_from_content(content_type, pulp_content_clauses)
        end
      end

      def package_clauses_from_content(content_type, pulp_content_clauses)
        case content_type
        when ContentViewFilter::ERRATA
          package_clauses_for_errata(pulp_content_clauses)
        when ContentViewFilter::PACKAGE_GROUP
          package_clauses_for_group(pulp_content_clauses)
        else
          {"$or" => pulp_content_clauses}
        end
      end

      # input ->  [{"type"=>{"$in"=>[:bugfix, :security]}}] <- Errata Pulp Clauses
      # output -> {"filename" => {"$in" => {"foo.el6.noarch", "..."}}} <- Packages belonging to those errata
      def package_clauses_for_errata(errata_clauses = [])
        pkg_filenames = Katello::Erratum.list_filenames_by_clauses(@repo, errata_clauses)
        {'filename' => {"$in" => pkg_filenames}} unless pkg_filenames.empty?
      end

      # input ->  [{"name"=>{"$in"=>["foo", "bar"]}}] <- Package group pulp clauses
      # output -> {"names" => {"$in" => {"foo", "..."}}}  <- packages belonging to those packages
      def package_clauses_for_group(group_clauses = [])
        group_clauses = {"$or" => group_clauses}
        pkg_names = Katello::PackageGroup.list_by_filter_clauses(group_clauses)
        {'name' => {"$in" => pkg_names}} unless pkg_names.empty?
      end
    end
  end
end
