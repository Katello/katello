#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Katello
    module System
      module Erratum
        class ApplicableErrataInstall < Actions::EntryAction
          #takes a list of errata and schedules the installation of those that are applicable
          def plan(system, errata_uuids)
            applicable_errata = system.applicable_errata.where(:uuid => errata_uuids)
            plan_action(Actions::Katello::System::Erratum::Install, system, applicable_errata.pluck(:errata_id))
          end

          def humanized_name
            _("Install Applicable Errata")
          end
        end
      end
    end
  end
end
