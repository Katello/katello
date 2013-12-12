#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module Util
    class PackageClauseGenerator
      include  Util::FilterRuleClauseGenerator

      protected

      def fetch_rules
        FilterRule.yum_types
      end

      def collect_clauses(repo, rules)
        [ErratumRule, PackageGroupRule, PackageRule].collect do |rule_class|
          content_type_rules = rules.where(:type => rule_class)
          make_package_clauses(repo, content_type_rules) unless content_type_rules.empty?
        end
      end

      def whitelist_non_matcher_clause
        {"filename" => {"$not" => {"$exists" => true}}}
      end

      def whitelist_all_matcher_clause
        {"filename" => {"$exists" => true}}
      end

      def make_package_clauses(repo, rules)
        content_type = rules.first.content_type
        pulp_content_clauses = rules.collect do |rule|
          rule.generate_clauses(repo)
        end
        pulp_content_clauses.flatten!
        pulp_content_clauses.compact!

        if !pulp_content_clauses.empty?
          package_clauses_from_content(content_type, pulp_content_clauses)
        end
      end

      def package_clauses_from_content(content_type, pulp_content_clauses)
        case content_type
        when FilterRule::ERRATA
          package_clauses_for_errata(pulp_content_clauses)
        when FilterRule::PACKAGE_GROUP
          package_clauses_for_group(pulp_content_clauses)
        else
          {"$or" => pulp_content_clauses}
        end
      end

      # input ->  [{"type"=>{"$in"=>[:bugfix, :security]}}] <- Errata Pulp Clauses
      # output -> {"filename" => {"$in" => {"foo.el6.noarch", "..."}}} <- Packages belonging to those errata
      def package_clauses_for_errata(errata_clauses = [])
        errata_clauses = {"$or" => errata_clauses}
        pkg_filenames = ::Errata.list_by_filter_clauses(errata_clauses).collect(&:package_filenames).flatten
        {'filename' => {"$in" => pkg_filenames}} unless pkg_filenames.empty?
      end

      # input ->  [{"name"=>{"$in"=>["foo", "bar"]}}] <- Package group pulp clauses
      # output -> {"names" => {"$in" => {"foo", "..."}}}  <- packages belonging to those packages
      def package_clauses_for_group(group_clauses = [])
        group_clauses = {"$or" => group_clauses}
        pkg_names = PackageGroup.list_by_filter_clauses(group_clauses).collect(&:package_names).flatten
        {'name' => {"$in" => pkg_names}} unless pkg_names.empty?
      end

    end
  end
end
