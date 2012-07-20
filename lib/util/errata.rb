#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# The Errata module contains methods that are common for supporting errata
# in several controllers (e.g. SystemErrataController and SystemGroupErrataController)
module Katello
  module Errata
    def filter_by_type errata_list, filter_type
      filtered_list = []

      if filter_type != "All"
        pulp_filter_type = get_pulp_filter_type(filter_type)

        errata_list.each{ |erratum|
          if erratum.class.name == "Glue::Pulp::Errata"
            if erratum.type == pulp_filter_type
              filtered_list << erratum
            end
          else
            if erratum["type"] == pulp_filter_type
              filtered_list << erratum
            end
          end
        }
      else
        filtered_list = errata_list
      end

      return filtered_list
    end

    def get_pulp_filter_type type
      filter_type = type.downcase
      if filter_type == "bug"
        return Glue::Pulp::Errata::BUGZILLA
      elsif filter_type == "enhancement"
        return Glue::Pulp::Errata::ENHANCEMENT
      elsif filter_type == "security"
        return Glue::Pulp::Errata::SECURITY
      end
    end

    def filter_by_state errata_list, errata_state
      if errata_state == "applied"
        return []
      else
        return errata_list
      end
    end

  end
end