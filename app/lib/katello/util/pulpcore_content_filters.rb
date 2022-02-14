module Katello
  module Util
    module PulpcoreContentFilters
      def filter_distribution_trees_by_pulp_hrefs(distributiontree_results, _content_pulp_hrefs)
        distributiontree_results.collect { |result| result.pulp_href }.flatten.uniq
      end

      def filter_package_groups_by_pulp_href(package_groups, package_pulp_hrefs)
        rpms = Katello::Rpm.where(:pulp_id => package_pulp_hrefs)
        package_groups.reject do |package_group|
          package_group.package_names.empty? ||
          (package_group.package_names - rpms.pluck(:name)).any?
        end
      end

      def filter_package_environments_by_pulp_hrefs(packageenvironment_results, package_pulp_hrefs)
        matching_package_env_groups = []

        packageenvironment_results.each do |result|
          if (result.packagegroups & package_pulp_hrefs).any?
            matching_package_env_groups << result.pulp_href
          end
        end

        matching_package_env_groups.flatten.uniq
      end

      def filter_metadatafiles_by_pulp_hrefs(metadatafiles_results, _package_pulp_hrefs)
        metadatafiles_results.collect { |result| result.pulp_href }.flatten.uniq
      end

      def filter_modulemd_defaults_by_pulp_hrefs(modulemd_defaults_results, content_pulp_hrefs)
        modulemd_defaults_results.collect { |result| result.pulp_href }.flatten.uniq
      end
    end
  end
end
