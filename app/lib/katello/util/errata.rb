# The Errata module contains methods that are common for supporting errata
# in several controllers (e.g. SystemErrataController and HostCollectionErrataController)
module Katello
  module Util
    module Errata
      def filter_by_type(errata_list, filter_type)
        filtered_list = []

        if filter_type != "All"
          pulp_filter_type = get_pulp_filter_type(filter_type)

          errata_list.each do |erratum|
            if erratum.respond_to?(:type)
              if erratum.type == pulp_filter_type
                filtered_list << erratum
              end
            else
              if erratum["type"] == pulp_filter_type
                filtered_list << erratum
              end
            end
          end
        else
          filtered_list = errata_list
        end

        return filtered_list
      end

      def get_pulp_filter_type(type)
        filter_type = type.downcase
        if filter_type == "bugfix"
          return ::Katello::Erratum::BUGZILLA
        elsif filter_type == "enhancement"
          return ::Katello::Erratum::ENHANCEMENT
        elsif filter_type == "security"
          return ::Katello::Erratum::SECURITY
        end
      end

      def filter_by_state(errata_list, errata_state)
        if errata_state == "applied"
          return []
        else
          return errata_list
        end
      end

      def filter_errata_by_pulp_href(errata, package_pulp_hrefs, source_repo_rpm_filenames)
        return [] if package_pulp_hrefs.empty?
        rpms = Katello::Rpm.where(:pulp_id => package_pulp_hrefs)
        srpms = Katello::Srpm.where(:pulp_id => package_pulp_hrefs)
        rpm_filenames = rpms.map { |rpm| File.basename(rpm.filename) }
        srpm_filenames = srpms.map { |srpm| File.basename(srpm.filename) }
        source_repo_rpm_filenames = source_repo_rpm_filenames.map { |rpm| File.basename(rpm) }
        matching_errata = []
        errata.each do |erratum|
          # The erratum should be copied if package_pulp_hrefs has all of its packages that are available in the source repo.
          rpms_in_erratum_and_source_repo = erratum.packages.pluck(:filename) & source_repo_rpm_filenames
          if (rpms_in_erratum_and_source_repo - rpm_filenames - srpm_filenames).empty? ||
              erratum.packages.empty? || rpms_in_erratum_and_source_repo.empty?
            matching_errata << erratum
          end
        end
        matching_errata
      end
    end
  end
end
