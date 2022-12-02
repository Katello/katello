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

      def filter_errata_by_pulp_href(errata, content_pulp_hrefs, source_repo_rpm_filenames, source_repo_module_stream_specs)
        return [] if content_pulp_hrefs.empty?

        source_repo_rpm_filenames = source_repo_rpm_filenames.map { |rpm| File.basename(rpm) }
        rpm_filenames = Katello::Rpm.where(:pulp_id => content_pulp_hrefs).map { |rpm| File.basename(rpm.filename) }
        srpm_filenames = Katello::Srpm.where(:pulp_id => content_pulp_hrefs).map { |srpm| File.basename(srpm.filename) }
        module_stream_specs = Katello::ModuleStream.where(:pulp_id => content_pulp_hrefs).map(&:module_spec)

        matching_errata = []
        errata.each do |erratum|
          # The erratum should be copied if content_pulp_hrefs has all of its packages/modules that are available in the source repo.
          content_in_erratum_and_source_repo =
            (erratum.packages.pluck(:filename) + erratum.module_stream_specs) & (source_repo_rpm_filenames + source_repo_module_stream_specs)
          if (content_in_erratum_and_source_repo - rpm_filenames - srpm_filenames - module_stream_specs).empty? ||
              (erratum.packages.empty? && erratum.module_streams.empty?) || content_in_erratum_and_source_repo.empty?
            matching_errata << erratum
          end
        end
        matching_errata
      end
    end
  end
end
