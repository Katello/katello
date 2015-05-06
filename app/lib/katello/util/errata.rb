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
    end
  end
end
